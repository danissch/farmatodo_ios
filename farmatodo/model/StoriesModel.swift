//
//  StoriesModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/2/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class StoriesModel: Decodable {
    let id: Int
    let title: String
    let description: String
    
    init(id: Int, title: String, description: String) {
        print("init :: StoriesModel")
        self.id = id
        self.title = title
        self.description = description
        
    }
}

class StoriesData: Decodable {
    let results: [StoriesModel]
}

class StoriesResponse: Decodable {
    let data: StoriesData
}

extension StoriesModel: Equatable {
    static func == (lhs: StoriesModel, rhs: StoriesModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description
    }
}
