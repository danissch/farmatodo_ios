//
//  StoriesViewModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/2/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class StoriesViewModel: StoriesViewModelProtocol {
 
    
    var networkService: NetworkServiceProtocol?
    var TAG: String = "StoriesViewModel"
    
    init() {
        print("init :: \(TAG)")
        privCurrentStory = StoriesModel(id: 0, title: "", description: "")
    }
    
    private let pageSize = 20
    
    private var privCurrentStory: StoriesModel
    var currentStory: StoriesModel {
        get { return privCurrentStory }
        set { privCurrentStory = newValue }
    }
    
    private var privStoryList = [StoriesModel]()
    var storiesList: [StoriesModel] {
        get { return privStoryList }
    }
    
    private var privComicList = [ComicModel]()
    var comicList: [ComicModel] {
        get { return privComicList }
    }
    
    
    func getStories(
        page: Int,
        complete: @escaping ( ServiceResult<[StoriesModel]?> ) -> Void )  {
        print("init :: getStories :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        //let url = "\(baseUrl)stories?\(hash)&offset=\(offset)&nameStartsWith=Sup"
        let url = "\(baseUrl)stories?\(hash)&offset=\(offset)"
        // TODO: filter: &nameStartsWith=Sup
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privStoryList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    //print(": getStories json ::\(json)")
                    print("case .Success :: getStories ::\(self!.TAG)")
                    if let data = json?.data(using: .utf8) {
                        
                        let decoder = JSONDecoder()
                        print("pequeña miga ...... ::\(self!.TAG)")
                        let storyResponse = try decoder.decode(StoriesResponse.self, from: data)
                        print("pequeña miga 2...... ::\(self!.TAG)")
                        print("storyResponse::: \(storyResponse)")
                        self?.privStoryList.append(contentsOf: storyResponse.data.results)
                        return complete(.Success(self?.privStoryList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error :: getStories")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
    func getStoryComics(
        page: Int,
        storyId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )  {
        print("getStoryComics :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        let url = "\(baseUrl)stories/\(storyId)/comics?\(hash)&offset=\(offset)"
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
                    print("case .Success getStoryComics :: \(self!.TAG) ")
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
                print("case .Error getStoryComics :: \(self?.TAG ?? "")")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
}
