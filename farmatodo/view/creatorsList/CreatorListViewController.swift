//
//  CreatorListViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class CreatorListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var TAG:String="CreatorListViewController"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBAction func playAgain(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var resultadoLabel: UILabel!
    var resultado:Int?
    
    var window: UIWindow?
    var creatorViewModel: CreatorViewModelProtocol?
    
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
    private var creatorCellSize: CGFloat = 0
    private var loadingCellSize: CGFloat = 0
    private var currentCreator: CreatorModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Estamos en viewDidLoad \(TAG)!!!")
        
        let creatorViewModel = CreatorViewModel()
        NetworkService.shared.alamofireWrapper = AlamofireWrapper()
        creatorViewModel.networkService = NetworkService.shared
        self.creatorViewModel = creatorViewModel
        self.window?.rootViewController = self
        self.window?.makeKeyAndVisible()
        
        pageView.setBlackBorder()
        computeSizes()
        loadNextPage()
        
        resultadoLabel.attributedText = NSAttributedString.fromString(string: "Resultado:  \(String(describing: resultado!))", lineHeightMultiple: 0.9)
        resultadoLabel.textAlignment = .center
    }
    
    private func computeSizes() {
        print("computeSizes \(TAG)!!!")
        screenWidth = UIScreen.main.bounds.width
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        //     10.0 = 10.0 --> border between 2 cells
        // sum      = 50.0
        // divide by 2.0, since there are 2 columns
        creatorCellSize = (screenWidth - 50.0) / 2.0
        
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
        let previousCount = creatorViewModel?.creatorList.count ?? 0
        creatorViewModel?.getCreators(page: _page) { [weak self] (result) in
            self?._isFirstLoading = false
            self?.isPullingUp = false
            self?.loadingData = false
            switch result {
            case .Success(_, _):
                self?.collectionView.reloadData()
                let count = self?.creatorViewModel?.creatorList.count ?? 0
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
        return _isFirstLoading ? 1 : (creatorViewModel?.creatorList.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("collectionView cellForItemAt \(TAG)!!!")
        if _isFirstLoading {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath)
        }
        if (indexPath.row >= (creatorViewModel?.creatorList.count ?? 0) - preloadCount) && !loadingData {
            loadNextPage()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "creatorListCell", for: indexPath) as! CreatorListCell
        let creatorModel = creatorViewModel!.creatorList[indexPath.row]
        cell.nameLabel.attributedText = NSAttributedString.fromString(string: creatorModel.fullName + "...", lineHeightMultiple: 0.7)
        cell.squareView.setBlackBorder()
        cell.nameView.setBlackBorder()
        
        let url = URL(string: creatorModel.thumbnail.fullName)
        cell.creatorImageView.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        print("collectionView viewForSupplementaryElementOfKind \(TAG)!!!")
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "creatorListHeader", for: indexPath) as! CreatorListHeader
            header.rectangleView.backgroundColor = .comicYellow
            header.rectangleView.setBlackBorder()
            return header
            
        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "creatorListFooter", for: indexPath)
            return footer
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView didSelectItemAt \(TAG)!!!")
        if !_isFirstLoading {
            if let creator = creatorViewModel?.creatorList[indexPath.row] {
                creatorViewModel?.currentCreator = creator
                self.performSegue(withIdentifier: "segueToCreator", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare \(TAG)!!!")
        if segue.identifier == "segueToCreator" {
            if let creatorViewController = segue.destination as? CreatorViewController {
                creatorViewController.creatorViewModel = creatorViewModel
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("collectionView sizeForItemAt \(TAG)!!!")
        let size = _isFirstLoading ? loadingCellSize : creatorCellSize
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
