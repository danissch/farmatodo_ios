//
//  SerieListViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class SerieListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var TAG:String="SerieListViewController"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    var window: UIWindow?
    var serieViewModel: SerieViewModelProtocol?
    
    private var _isFirstLoading = true
    private var _noFurtherData = false
    private var _page = -1
    
    // used on tests (read only)
    var isFirstLoading: Bool { get { return _isFirstLoading } }
    var noFurtherData: Bool { get { return _noFurtherData } }
    var page: Int { get { return _page } }
    
    private var isPullingUp = false
    private var loadingData = false
    private let preloadCount = 10
    private var screenWidth: CGFloat = 0
    private var serieCellSize: CGFloat = 0
    private var loadingCellSize: CGFloat = 0
    private var currentSerie: SerieModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Estamos en viewDidLoad \(TAG)!!!")
        
        let serieViewModel = SerieViewModel()
        NetworkService.shared.alamofireWrapper = AlamofireWrapper()
        serieViewModel.networkService = NetworkService.shared
        self.serieViewModel = serieViewModel
        self.window?.rootViewController = self
        self.window?.makeKeyAndVisible()
        
        pageView.setBlackBorder()
        computeSizes()
        loadNextPage()
    }
    
    private func computeSizes() {
        print("computeSizes \(TAG)!!!")
        screenWidth = UIScreen.main.bounds.width
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        //     10.0 = 10.0 --> border between 2 cells
        // sum      = 50.0
        // divide by 2.0, since there are 2 columns
        serieCellSize = (screenWidth - 50.0) / 2.0
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        // sum      = 40.0
        loadingCellSize = screenWidth - 40.0
    }
    
    func loadNextPage() {
        print("loadNextPage \(TAG)!!!")
        if loadingData || _noFurtherData {
            return
        }
        _page += 1
        loadingData = true
        let previousCount = serieViewModel?.serieList.count ?? 0
        serieViewModel?.getSeries(page: _page) { [weak self] (result) in
            self?._isFirstLoading = false
            self?.isPullingUp = false
            self?.loadingData = false
            switch result {
            case .Success(_, _):
                self?.collectionView.reloadData()
                let count = self?.serieViewModel?.serieList.count ?? 0
                if count == previousCount {
                    self?._noFurtherData = true
                }
            case .Error(let message, let statusCode):
                print("Error \(message) \(statusCode ?? 0)")
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections \(TAG)!!!")
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionView \(TAG)!!!")
        return _isFirstLoading ? 1 : (serieViewModel?.serieList.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("collectionView cellForItemAt \(TAG)!!!")
        if _isFirstLoading {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath)
        }
        if (indexPath.row >= (serieViewModel?.serieList.count ?? 0) - preloadCount) && !loadingData {
            loadNextPage()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serieListCell", for: indexPath) as! SerieListCell
        let serieModel = serieViewModel!.serieList[indexPath.row]
        cell.nameLabel.attributedText = NSAttributedString.fromString(string: serieModel.title + "...", lineHeightMultiple: 0.7)
        cell.squareView.setBlackBorder()
        cell.nameView.setBlackBorder()
        // this will create a diagonal grid with pink/blue background colors for character names
//        let remanderBy4 = indexPath.row % 4
//        cell.nameView.backgroundColor = remanderBy4 == 1 || remanderBy4 == 2 ? .comicPink : .comicBlue
        let url = URL(string: serieModel.thumbnail.fullName)
        cell.serieImageView.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        print("collectionView viewForSupplementaryElementOfKind \(TAG)!!!")
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "serieListHeader", for: indexPath) as! SerieListHeader
            header.rectangleView.backgroundColor = .comicYellow
            header.rectangleView.setBlackBorder()
            return header
            
        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "serieListFooter", for: indexPath)
            return footer
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView didSelectItemAt \(TAG)!!!")
        if !_isFirstLoading {
            if let serie = serieViewModel?.serieList[indexPath.row] {
                serieViewModel?.currentSerie = serie
                self.performSegue(withIdentifier: "segueToSerie", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare \(TAG)!!!")
        if segue.identifier == "segueToSerie" {
            if let serieViewController = segue.destination as? SerieViewController {
                serieViewController.serieViewModel = serieViewModel
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("collectionView sizeForItemAt \(TAG)!!!")
        let size = _isFirstLoading ? loadingCellSize : serieCellSize
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("collectionView referenceSizeForHeaderInSection \(TAG)!!!")
        return CGSize(width: loadingCellSize, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        print("collectionView referenceSizeForFooterInSection \(TAG)!!!")
        return CGSize(width: loadingCellSize, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        print("collectionView minimumInteritemSpacingForSectionAt \(TAG)!!!")
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("collectionView minimumLineSpacingForSectionAt \(TAG)!!!")
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("collectionView insetForSectionAt \(TAG)!!!")
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    // MARK: - scrollView protocols
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll \(TAG)!!!")
        if isPullingUp {
            return
        }
        let scrollThreshold:CGFloat = 30
        let scrollDelta = (scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height
        if  scrollDelta > scrollThreshold {
            isPullingUp = true
            loadNextPage()
        }
    }
    
}
