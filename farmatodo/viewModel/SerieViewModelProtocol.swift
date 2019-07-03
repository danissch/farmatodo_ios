//
//  SerieViewModelProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/3/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation


protocol SerieViewModelProtocol {
    
    func getSeries(
        page: Int,
        complete: @escaping ( ServiceResult<[SerieModel]?> ) -> Void )
    
    var serieList: [SerieModel] { get }
    
    var currentSerie: SerieModel { get set }
    
    func getSerieComics(
        page: Int,
        eventId: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )
    
    var comicList: [ComicModel] { get }
    
}
