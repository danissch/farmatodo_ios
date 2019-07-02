//
//  StoriesViewModelProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/2/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation


protocol StoriesViewModelProtocol {
    
    func getStories(
        page: Int,
        complete: @escaping ( ServiceResult<[StoriesModel]?> ) -> Void )
    
    var storiesList: [StoriesModel] { get }
    
    var currentStory: StoriesModel { get set }
    
    func getStoryComics(
        page: Int,
        storyId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var comicList: [ComicModel] { get }
    
}
