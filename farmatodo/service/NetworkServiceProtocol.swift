//
//  NetworkServiceProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import Alamofire

enum ServiceResult<T> {
    case Success(T, Int)
    case Error(String, Int?)
}

protocol NetworkServiceProtocol {
    
    var apiKeyTsHash: String { get }
    
    var baseUrl: String { get }
    
    func request(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        complete: @escaping ( ServiceResult<String?> ) -> Void )
    
}
