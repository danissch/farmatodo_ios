//
//  CreatorModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class CreatorModel: Decodable {
    let id: Int
    let fullName: String
    let thumbnail: ThumbnailModel
    
    init(id: Int, fullName: String, thumbnail: ThumbnailModel) {
        print("init :: CreatorModel")
        self.id = id
        self.fullName = fullName
        self.thumbnail = thumbnail
    }
}

class CreatorData: Decodable {
    let results: [CreatorModel]
}

class CreatorResponse: Decodable {
    let data: CreatorData
}

extension CreatorModel: Equatable {
    static func == (lhs: CreatorModel, rhs: CreatorModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.fullName == rhs.fullName &&
            lhs.thumbnail == rhs.thumbnail
    }
}
