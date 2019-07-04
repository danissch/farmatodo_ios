//
//  EventViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var TAG:String = "EventViewController"
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var eventViewModel: EventViewModelProtocol?
    
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
    private var eventCellSize: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageView.setBlackBorder()
        computeSizes()
        loadNextPage()
    }
    
    func loadNextPage() {
        if loadingData || _noFurtherData {
            return
        }
        _page += 1
        loadingData = true
        // TODO: create error treatment below (should never happen)
        let id = eventViewModel?.currentEvent.id ?? 0
        let previousCount = eventViewModel?.comicList.count
        eventViewModel?.getEventComics(page: _page, eventId: id){ [weak self] (result) in
            self?._isFirstLoading = false
            self?.isPullingUp = false
            self?.loadingData = false
            switch result {
            case .Success(_, _):
                self?.collectionView.reloadData()
                let count = self?.eventViewModel?.comicList.count ?? 0
                if count == previousCount {
                    self?._noFurtherData = true
                }
            case .Error(let message, let statusCode):
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
        eventCellSize = screenWidth - 40.0
        
        
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
        return _isFirstLoading ? 0 : (eventViewModel?.comicList.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let eventModel = eventViewModel?.currentEvent else {
                print("error reading Model")
                // TO DO: (this should never happen) - improve error treatment
                return comicsTitleCell(withString: "error", at: indexPath)
            }
            switch indexPath.row {
            case 0: return eventCell(forEventModel: eventModel, at: indexPath)
            case 1: return descriptionCell(forEventModel: eventModel, at: indexPath)
            default: return comicsTitleCell(withString: "comics", at: indexPath)
            }
        } else {
            let count = eventViewModel?.comicList.count ?? 0
            if (indexPath.row >= count - preloadCount) && !loadingData {
                loadNextPage()
            }
            let comicModel = eventViewModel?.comicList[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "comicCell", for: indexPath) as! ComicCell
            cell.titleLabel.text = comicModel?.title ?? ""
            cell.squareView.setBlackBorder()
            cell.titleView.setBlackBorder()
            cell.titleView.backgroundColor = .white
            if let uri = comicModel?.thumbnail.fullName{
                let url = URL(string: uri)
                cell.coverImageView.kf.setImage(with: url)
            }
            return cell
        }
    }
    
    private func eventCell(forEventModel eventModel: EventModel, at indexPath: IndexPath) -> EventCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCell
        cell.nameLabel.attributedText = NSAttributedString.fromString(string: eventModel.title, lineHeightMultiple: 0.7)
        cell.squareView.setBlackBorder()
        cell.nameView.setBlackBorder()
        cell.nameView.backgroundColor = .comicYellow
        let url = URL(string: eventModel.thumbnail.fullName)
        cell.eventImageView.kf.setImage(with: url)
        return cell
    }
    
    private func descriptionCell(forEventModel eventModel: EventModel, at indexPath: IndexPath) -> DescriptionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! DescriptionCell
        cell.squareView.setBlackBorder()
        cell.squareView.backgroundColor = .comicYellow
        cell.descriptionLabel.attributedText = NSAttributedString.fromString(string: eventModel.description, lineHeightMultiple: 0.7)
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
            let size = eventCellSize
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
        return CGSize(width: eventCellSize, height: 10)
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
