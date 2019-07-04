//
//  ComicFullModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class ComicFullModel: Decodable {
    let id: Int
    let title: String
    let format: String
    let thumbnail: ThumbnailModel
    
    
    init(id: Int, title: String, format:String, thumbnail: ThumbnailModel) {
    //init(id: Int, title: String, thumbnail: ThumbnailModel) {
        print("init :: CharacterModel")
        self.id = id
        self.title = title
        self.format = format
        self.thumbnail = thumbnail
        
        
    }
}

class ComicFullData: Decodable {
    let results: [ComicFullModel]
}

class ComicFullResponse: Decodable {
    let data: ComicFullData
}

extension ComicFullModel: Equatable {
    static func == (lhs: ComicFullModel, rhs: ComicFullModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.format == rhs.format &&
            lhs.thumbnail == rhs.thumbnail
        
    }
}
