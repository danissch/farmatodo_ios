//
//  EventModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class EventModel: Decodable {
    let id: Int
    let title: String
    let thumbnail: ThumbnailModel
    let description: String
    
    init(id: Int, title: String, thumbnail: ThumbnailModel, description: String) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.description = description
    }
}

class EventData: Decodable {
    let results: [EventModel]
}

class EventResponse: Decodable {
    let data: EventData
}

extension EventModel: Equatable {
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.thumbnail == rhs.thumbnail &&
            lhs.description == rhs.description 
    }
}
