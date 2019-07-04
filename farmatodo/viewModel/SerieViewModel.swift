//
//  SerieViewModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class SerieViewModel: SerieViewModelProtocol {
    
    var networkService: NetworkServiceProtocol?
    var TAG: String = "SerieViewModel"
    
    init() {
        print("init :: \(TAG)")
        privCurrentSerie = SerieModel(id: 0, title: "", thumbnail: ThumbnailModel(path: "", ext: ""))
    }
    
    private let pageSize = 20
    
    private var privCurrentSerie: SerieModel
    var currentSerie: SerieModel {
        get { return privCurrentSerie }
        set { privCurrentSerie = newValue }
    }
    
    private var privSerieList = [SerieModel]()
    var serieList: [SerieModel] {
        get { return privSerieList }
    }
    
    private var privComicList = [ComicModel]()
    var comicList: [ComicModel] {
        get { return privComicList }
    }
    
    
    func getSeries(
        page: Int,
        complete: @escaping ( ServiceResult<[SerieModel]?> ) -> Void )  {
        print("init :: getSeries :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        //let url = "\(baseUrl)stories?\(hash)&offset=\(offset)&nameStartsWith=Sup"
        let url = "\(baseUrl)series?\(hash)&offset=\(offset)"
        // TODO: filter: &nameStartsWith=Sup
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privSerieList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    //print(": getStories json ::\(json)")
                    print("case .Success :: getSeries ::\(self!.TAG)")
                    if let data = json?.data(using: .utf8) {
                        
                        let decoder = JSONDecoder()
                        
                        let serieResponse = try decoder.decode(SerieResponse.self, from: data)
                        
                        
                        self?.privSerieList.append(contentsOf: serieResponse.data.results)
                        return complete(.Success(self?.privSerieList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error :: getSeries")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
    func getSerieComics(
        page: Int,
        serieId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )  {
        print("getSerieComics :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        let url = "\(baseUrl)series/\(serieId)/comics?\(hash)&offset=\(offset)"
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
                    print("case .Success getSerieComics :: \(self!.TAG) ")
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
                print("case .Error getSerieComics :: \(self?.TAG ?? "")")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
}
