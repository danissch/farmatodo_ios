//
//  CharacterViewModelProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation


protocol CharacterViewModelProtocol {
    
    func getCharacters(
        page: Int,
        complete: @escaping ( ServiceResult<[CharacterModel]?> ) -> Void )
    
    var characterList: [CharacterModel] { get }
    
    var currentCharacter: CharacterModel { get set }
    
    func getCharacterComics(
        page: Int,
        character: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var comicList: [ComicModel] { get }
    
}
