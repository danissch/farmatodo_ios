//
//  StoriesListViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/2/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class StoriesListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var TAG:String = "StoriesListViewController"
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    
    @IBOutlet weak var playAgainButton: UIBarButtonItem!
    
    
    @IBOutlet weak var resultadoLabel: UILabel!
    var resultado:Int?
    
    @IBAction func playAgain(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    var window: UIWindow?
    var storiesViewModel: StoriesViewModelProtocol?
    
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
    private var storiesCellSize: CGFloat = 0
    private var loadingCellSize: CGFloat = 0
    private var currentStories: StoriesModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Tambien por viewDidLoad \(TAG)!!!")
        
        let storiesViewModel = StoriesViewModel()
        NetworkService.shared.alamofireWrapper = AlamofireWrapper()
        storiesViewModel.networkService = NetworkService.shared
        self.storiesViewModel = storiesViewModel
        self.window?.rootViewController = self
        self.window?.makeKeyAndVisible()
        self.toolBar.isHidden = false
        
        pageView.setBlackBorder()
        computeSizes()
        loadNextPage()
        //resultadoLabel.text = "Resultado: \(resultado)"
        resultadoLabel.attributedText = NSAttributedString.fromString(string: "Resultado:  \(String(describing: resultado!))", lineHeightMultiple: 0.9)
        resultadoLabel.textAlignment = .center
        playAgainButton.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Comic Book", size: 26.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.red],
                                          for: .normal)
        
    }
    
    private func computeSizes() {
        print("computeSizes StoriesListViewController!!!")
        screenWidth = UIScreen.main.bounds.width
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        //     10.0 = 10.0 --> border between 2 cells
        // sum      = 50.0
        // divide by 2.0, since there are 2 columns
        storiesCellSize = (screenWidth - 50.0) / 2.0
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        // sum      = 40.0
        loadingCellSize = screenWidth - 40.0
    }
    
    func loadNextPage() {
        print("loadNextPage StoriesListViewController!!!")
        if loadingData || _noFurtherData {
            return
        }
        _page += 1
        loadingData = true
        let previousCount = storiesViewModel?.storiesList.count ?? 0
        storiesViewModel?.getStories(page: _page) { [weak self] (result) in
            self?._isFirstLoading = false
            self?.isPullingUp = false
            self?.loadingData = false
            switch result {
            case .Success(_, _):
                self?.collectionView.reloadData()
                let count = self?.storiesViewModel?.storiesList.count ?? 0
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
        print("numberOfSections StoriesListViewController!!!")
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionView StoriesListViewController!!!")
        return _isFirstLoading ? 1 : (storiesViewModel?.storiesList.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("collectionView cellForItemAt StoriesListViewController!!!")
        if _isFirstLoading {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath)
        }
        if (indexPath.row >= (storiesViewModel?.storiesList.count ?? 0) - preloadCount) && !loadingData {
            loadNextPage()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storiesListCell", for: indexPath) as! StoriesListCell
        let storiesModel = storiesViewModel!.storiesList[indexPath.row]
        
        cell.nameLabel.attributedText = NSAttributedString.fromString(string: storiesModel.title + "...", lineHeightMultiple: 0.9)
        cell.squareView.setBlackBorder()
        cell.nameView.setBlackBorder()
        // this will create a diagonal grid with pink/blue background colors for character names
        let remanderBy4 = indexPath.row % 4
        cell.nameView.backgroundColor = remanderBy4 == 1 || remanderBy4 == 2 ? .comicPink : .comicBlue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        print("collectionView viewForSupplementaryElementOfKind StoriesListViewController!!!")
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "storiesListHeader", for: indexPath) as! StoriesListHeader
            header.rectangleView.backgroundColor = .comicYellow
            header.rectangleView.setBlackBorder()
            return header
            
        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "storiesListFooter", for: indexPath)
            return footer
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView didSelectItemAt StoriesListViewController!!!")
        if !_isFirstLoading {
            if let story = storiesViewModel?.storiesList[indexPath.row] {
                storiesViewModel?.currentStory = story
                self.performSegue(withIdentifier: "segueToStory", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare StoriesListViewController!!!")
        if segue.identifier == "segueToStory" {
            if let storyViewController = segue.destination as? StoryViewController {
                storyViewController.storiesViewModel = storiesViewModel
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("collectionView sizeForItemAt StoriesListViewController!!!")
        let size = _isFirstLoading ? loadingCellSize : storiesCellSize
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("collectionView referenceSizeForHeaderInSection StoriesListViewController!!!")
        return CGSize(width: loadingCellSize, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        print("collectionView referenceSizeForFooterInSection StoriesListViewController!!!")
        return CGSize(width: loadingCellSize, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        print("collectionView minimumInteritemSpacingForSectionAt StoriesListViewController!!!")
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("collectionView minimumLineSpacingForSectionAt StoriesListViewController!!!")
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("collectionView insetForSectionAt StoriesListViewController!!!")
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    // MARK: - scrollView protocols
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll StoriesListViewController!!!")
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
