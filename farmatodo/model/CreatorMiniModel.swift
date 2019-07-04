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
    let title: String
    
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}

extension CreatorMiniModel: Equatable {
    static func == (lhs: CreatorMiniModel, rhs: CreatorMiniModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title
    }
}

class CreatorMiniData: Decodable {
    let results: [CreatorMiniModel]
}

class CreatorMiniResponse: Decodable {
    let data: CreatorMiniData
}
