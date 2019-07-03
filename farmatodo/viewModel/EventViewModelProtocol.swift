//
//  EventViewModelProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation


protocol EventViewModelProtocol {
    
    func getEvents(
        page: Int,
        complete: @escaping ( ServiceResult<[EventModel]?> ) -> Void )
    
    var eventList: [EventModel] { get }
    
    var currentEvent: EventModel { get set }
    
    func getEventComics(
        page: Int,
        eventId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var comicList: [ComicModel] { get }
    
}
