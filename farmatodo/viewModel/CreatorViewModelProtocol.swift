//
//  CreatorViewModelProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation


protocol CreatorViewModelProtocol {
    
    func getCreators(
        page: Int,
        complete: @escaping ( ServiceResult<[CreatorModel]?> ) -> Void )
    
    var creatorList: [CreatorModel] { get }
    
    var currentCreator: CreatorModel { get set }
    
    func getCreatorComics(
        page: Int,
        creatorId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var comicList: [ComicModel] { get }
    
}
