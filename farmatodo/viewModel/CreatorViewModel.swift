//
//  CreatorViewModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class CreatorViewModel: CreatorViewModelProtocol {
    
    
    var networkService: NetworkServiceProtocol?
    var TAG: String = "CreatorViewModel"
    
    init() {
        print("init :: \(TAG)")
        privCurrentCreator = CreatorModel(id: 0, fullName: "", thumbnail: ThumbnailModel(path: "", ext: ""))
    }
    
    private let pageSize = 20
    
    private var privCurrentCreator: CreatorModel
    var currentCreator: CreatorModel {
        get { return privCurrentCreator }
        set { privCurrentCreator = newValue }
    }
    
    private var privCreatorList = [CreatorModel]()
    var creatorList: [CreatorModel] {
        get { return privCreatorList }
    }
    
    private var privComicList = [ComicModel]()
    var comicList: [ComicModel] {
        get { return privComicList }
    }
    
    
    func getCreators(
        page: Int,
        complete: @escaping ( ServiceResult<[CreatorModel]?> ) -> Void )  {
        print("init :: getCreators :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        //let url = "\(baseUrl)stories?\(hash)&offset=\(offset)&nameStartsWith=Sup"
        let url = "\(baseUrl)creators?\(hash)&offset=\(offset)"
        // TODO: filter: &nameStartsWith=Sup
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privCreatorList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    //print(": getStories json ::\(json)")
                    print("case .Success :: getCreators ::\(self!.TAG)")
                    if let data = json?.data(using: .utf8) {
                        
                        let decoder = JSONDecoder()
                        
                        let creatorResponse = try decoder.decode(CreatorResponse.self, from: data)
        
                        
                        self?.privCreatorList.append(contentsOf: creatorResponse.data.results)
                        return complete(.Success(self?.privCreatorList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error :: getCreators")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
    func getCreatorComics(
        page: Int,
        creatorId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )  {
        print("getCreatorComics :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        let url = "\(baseUrl)creators/\(creatorId)/comics?\(hash)&offset=\(offset)"
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
                    print("case .Success getCreatorComics :: \(self!.TAG) ")
                    if let data = json?.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        let comicResponse = try decoder.decode(ComicResponse.self, from: data)
                        self?.privComicList.append(contentsOf: comicResponse.data.results)
                        return complete(.Success(self?.privComicList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error getCreatorComics :: \(self?.TAG ?? "")")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
}
