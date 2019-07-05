//
//  CreatorViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class CreatorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    private var coverWidth: CGFloat = 0
    private var coverHeight: CGFloat = 0
    private var creatorCellSize: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageView.setBlackBorder()
        computeSizes()
        loadNextPage()
    }
    
    func loadNextPage() {
        print("loadNextPage")
        if loadingData || _noFurtherData {
            return
        }
        _page += 1
        loadingData = true
        // TODO: create error treatment below (should never happen)
        let id = creatorViewModel?.currentCreator.id ?? 0
        print("id:::::\(id)")
        let previousCount = creatorViewModel?.comicList.count
        print("previousCount:: \(previousCount)")
        creatorViewModel?.getCreatorComics(page: _page, creatorId: id){ [weak self] (result) in
            self?._isFirstLoading = false
            self?.isPullingUp = false
            self?.loadingData = false
            switch result {
            case .Success(_, _):
                print("Success:result: \(result)")
                self?.collectionView.reloadData()
                let count = self?.creatorViewModel?.comicList.count ?? 0
                if count == previousCount {
                    self?._noFurtherData = true
                }
            case .Error(let message, let statusCode):
                print("Error:result: \(result)")
                print("Error \(message) \(statusCode ?? 0)")
            }
        }
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func computeSizes() {
        screenWidth = UIScreen.main.bounds.width
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        // sum      = 40.0
        creatorCellSize = screenWidth - 40.0
        
        
        // 2 * 10.0 = 20.0 --> external border
        // 2 * 10.0 = 20.0 --> internal border
        //     10.0 = 10.0 --> border between 2 cells
        // sum      = 50.0
        // divide by 2.0, since there are 2 columns
        coverWidth = (screenWidth - 50.0) / 2.0
        
        // keep a proportion, cover is portrait (height larger then width)
        coverHeight = coverWidth * 1.86
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return _isFirstLoading ? 0 : (creatorViewModel?.comicList.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            print("Hey por aqui")
            guard let creatorModel = creatorViewModel?.currentCreator else {
                print("Hey por aqui 2")
                print("error reading creatorModel")
                // TO DO: (this should never happen) - improve error treatment
                return comicsTitleCell(withString: "error", at: indexPath)
            }
            switch indexPath.row {
            case 0: return creatorCell(forCreatorModel: creatorModel, at: indexPath)
            case 1: return descriptionCell(forCreatorModel: creatorModel, at: indexPath)
            default: return comicsTitleCell(withString: "comics", at: indexPath)
            }
        } else {
            let count = creatorViewModel?.comicList.count ?? 0
            if (indexPath.row >= count - preloadCount) && !loadingData {
                loadNextPage()
            }
            let comicModel = creatorViewModel?.comicList[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "comicCell", for: indexPath) as! ComicCell
            cell.titleLabel.text = comicModel?.title
            cell.squareView.setBlackBorder()
            cell.titleView.setBlackBorder()

            if let uri = comicModel?.thumbnail.fullName{
                let url = URL(string: uri)
                cell.coverImageView.kf.setImage(with: url)
            }
            return cell
        }
    }
    
    private func creatorCell(forCreatorModel creatorModel: CreatorModel, at indexPath: IndexPath) -> CreatorCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "creatorCell", for: indexPath) as! CreatorCell
        cell.nameLabel.attributedText = NSAttributedString.fromString(string: String(creatorModel.id), lineHeightMultiple: 0.7)
        cell.squareView.setBlackBorder()
        cell.nameView.setBlackBorder()
        cell.nameView.backgroundColor = .comicYellow
        let url = URL(string: creatorModel.thumbnail.fullName)
        cell.characterImageView.kf.setImage(with: url)
        return cell
    }
    
    private func descriptionCell(forCreatorModel creatorModel: CreatorModel, at indexPath: IndexPath) -> DescriptionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! DescriptionCell
        cell.squareView.setBlackBorder()
        cell.squareView.backgroundColor = .comicYellow
        cell.descriptionLabel.attributedText = NSAttributedString.fromString(string: creatorModel.fullName, lineHeightMultiple: 0.7)
        return cell
    }
    
    private func comicsTitleCell(withString string: String, at indexPath: IndexPath) -> ComicsTitleCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "comicsTitleCell", for: indexPath) as! ComicsTitleCell
        cell.comicsLabel.attributedText = NSAttributedString.fromString(string: string, lineHeightMultiple: 0.7)
        cell.squareView.setBlackBorder()
        cell.squareView.backgroundColor = .comicYellow
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let size = creatorCellSize
            let height: CGFloat
            switch indexPath.row {
            case 0:
                height = size
            case 1:
                height = 100
            default:
                height = 33
            }
            return CGSize(width: size, height: height)
        }
        return CGSize(width: coverWidth, height: coverHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: creatorCellSize, height: 10)
    }
    
    // MARK: - scrollView protocols
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
