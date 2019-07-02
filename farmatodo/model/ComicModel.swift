//
//  ComicModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class ComicModel: Decodable {
    let id: Int
    let title: String
    let thumbnail: ThumbnailModel
    
    init(id: Int, title: String, thumbnail: ThumbnailModel) {
        print("init :: ComicModel")
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
    }
}

extension ComicModel: Equatable {
    static func == (lhs: ComicModel, rhs: ComicModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.thumbnail == rhs.thumbnail
    }
}

class ComicData: Decodable {
    let results: [ComicModel]
}

class ComicResponse: Decodable {
    let data: ComicData
}
