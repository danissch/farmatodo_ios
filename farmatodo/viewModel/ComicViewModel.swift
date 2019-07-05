//
//  ComicViewModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/2/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class ComicViewModel: ComicViewModelProtocol {
    
    var networkService: NetworkServiceProtocol?
    var TAG:String = "ComicViewModel"
    
    init() {
        print("init :: \(TAG)")
        //privCurrentComic = ComicFullModel(id: 0, title: "", thumbnail: ThumbnailModel(path: "", ext: ""), description: "")
        privCurrentComic = ComicFullModel(id: 0, title: "", variantDescription: "", description: "", thumbnail: ThumbnailModel(path: "", ext: ""))
    }
    
    private let pageSize = 20
    
    private var privCurrentComic: ComicFullModel
    var currentComic: ComicFullModel {
        get { return privCurrentComic }
        set { privCurrentComic = newValue }
    }
    
    private var privComicList = [ComicFullModel]()
    var comicList: [ComicFullModel] {
        get { return privComicList }
    }
    
    private var privCreatorsList = [CreatorMiniModel]()
    var creatorsList: [CreatorMiniModel] {
        get { return privCreatorsList }
    }
    
    func getComics(
        page: Int,
        complete: @escaping ( ServiceResult<[ComicFullModel]?> ) -> Void )  {
        print("init :: getCharacters")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        //let url = "\(baseUrl)characters?\(hash)&offset=\(offset)&nameStartsWith=Spi"
        let url = "\(baseUrl)comics?\(hash)&offset=\(offset)"
        // TODO: filter: &nameStartsWith=Spi
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privComicList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    print("case .Success :: getComics")
                    if let data = json?.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        let comicResponse = try decoder.decode(ComicFullResponse.self, from: data)
                        self?.privComicList.append(contentsOf: comicResponse.data.results)
                        return complete(.Success(self?.privComicList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error :: getCharacters")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
    func getComicCreators(
        page: Int,
        comicId: Int,
        complete: @escaping ( ServiceResult<[CreatorMiniModel]?> ) -> Void )  {
        print("getComicCreators :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        let url = "\(baseUrl)comics/\(comicId)/creators?\(hash)&offset=\(offset)"
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privCreatorsList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    print("case .Success getComicCreators :: \(self!.TAG)")
                    if let data = json?.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        let creatorResponse = try decoder.decode(CreatorMiniResponse.self, from: data)
                        self?.privCreatorsList.append(contentsOf: creatorResponse.data.results)
                        return complete(.Success(self?.privCreatorsList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error getComicCreators :: \(self!.TAG)")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
}
