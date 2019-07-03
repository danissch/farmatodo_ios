//
//  SerieModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class SerieModel: Decodable {
    let id: Int
    let title: String
    let thumbnail: ThumbnailModel
    
    init(id: Int, title: String, thumbnail: ThumbnailModel) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
    }
}

class SerieData: Decodable {
    let results: [SerieModel]
}

class SerieResponse: Decodable {
    let data: SerieData
}

extension SerieModel: Equatable {
    static func == (lhs: SerieModel, rhs: SerieModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.thumbnail == rhs.thumbnail
    }
}
