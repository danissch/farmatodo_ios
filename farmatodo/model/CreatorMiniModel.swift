//
//  CreatorMiniModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class CreatorMiniModel: Decodable {
    let id: Int
    let fullName: String
    let thumbnail: ThumbnailModel
    
    
    init(id: Int, fullName: String, thumbnail: ThumbnailModel) {
        self.id = id
        self.fullName = fullName
        self.thumbnail = thumbnail
    }
}

extension CreatorMiniModel: Equatable {
    static func == (lhs: CreatorMiniModel, rhs: CreatorMiniModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.fullName == rhs.fullName &&
            lhs.thumbnail == rhs.thumbnail
    }
}

class CreatorMiniData: Decodable {
    let results: [CreatorMiniModel]
}

class CreatorMiniResponse: Decodable {
    let data: CreatorMiniData
}
