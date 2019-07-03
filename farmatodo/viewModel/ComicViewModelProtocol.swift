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
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var characterList: [CharacterModel] { get }
    
    var currentComic: ComicModel { get set }
    
    func getCharacterComics(
        page: Int,
        character: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var comicList: [ComicModel] { get }
    
}
