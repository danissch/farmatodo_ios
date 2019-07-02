//
//  CharacterModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class CharacterModel: Decodable {
    let id: Int
    let name: String
    let thumbnail: ThumbnailModel
    let description: String
    
    init(id: Int, name: String, thumbnail: ThumbnailModel, description: String) {
        print("init :: CharacterModel")
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.description = description
        print("name:: \(name)")
    }
}

class CharacterData: Decodable {
    let results: [CharacterModel]
}

class CharacterResponse: Decodable {
    let data: CharacterData
}

extension CharacterModel: Equatable {
    static func == (lhs: CharacterModel, rhs: CharacterModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.thumbnail == rhs.thumbnail &&
            lhs.description == rhs.description
    }
}
