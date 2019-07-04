//
//  ComicViewModelProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/2/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation


protocol ComicViewModelProtocol {
    
    func getComics(
        page: Int,
        complete: @escaping ( ServiceResult<[ComicFullModel]?> ) -> Void )
    
    var comicList: [ComicFullModel] { get }
    
    var currentComic: ComicFullModel { get set }
    
    func getComicCreators(
        page: Int,
        comicId: Int,
        complete: @escaping ( ServiceResult<[CreatorMiniModel]?> ) -> Void )
    
    var creatorsList: [CreatorMiniModel] { get }
    
}
