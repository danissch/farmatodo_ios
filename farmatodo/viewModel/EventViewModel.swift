//
//  EventViewModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class EventViewModel: EventViewModelProtocol {
    
    var networkService: NetworkServiceProtocol?
    var TAG: String = "EventViewModel"
    
    init() {
        print("init :: \(TAG)")
        privCurrentEvent = EventModel(id: 0, title: "", thumbnail: ThumbnailModel(path: "", ext: ""))
    }
    
    private let pageSize = 20
    
    private var privCurrentEvent: EventModel
    var currentEvent: EventModel {
        get { return privCurrentEvent }
        set { privCurrentEvent = newValue }
    }
    
    private var privEventList = [EventModel]()
    var eventList: [EventModel] {
        get { return privEventList }
    }
    
    private var privComicList = [ComicModel]()
    var comicList: [ComicModel] {
        get { return privComicList }
    }
    
    
    func getEvents(
        page: Int,
        complete: @escaping ( ServiceResult<[EventModel]?> ) -> Void )  {
        print("init :: getEvents :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        //let url = "\(baseUrl)stories?\(hash)&offset=\(offset)&nameStartsWith=Sup"
        let url = "\(baseUrl)events?\(hash)&offset=\(offset)"
        // TODO: filter: &nameStartsWith=Sup
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privEventList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    //print(": getStories json ::\(json)")
                    print("case .Success :: getEvents ::\(self!.TAG)")
                    if let data = json?.data(using: .utf8) {
                        
                        let decoder = JSONDecoder()
                        
                        let eventResponse = try decoder.decode(EventResponse.self, from: data)
                        
                        
                        self?.privEventList.append(contentsOf: eventResponse.data.results)
                        return complete(.Success(self?.privEventList, statusCode))
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
    
    func getEventComics(
        page: Int,
        eventId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )  {
        print("getEventComics :: \(TAG)")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        let url = "\(baseUrl)events/\(eventId)/comics?\(hash)&offset=\(offset)"
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
