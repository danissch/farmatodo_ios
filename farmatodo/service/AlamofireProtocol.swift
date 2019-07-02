//
//  AlamofireProtocol.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import Alamofire

protocol AlamofireProtocol {
    
    func responseString(
        _ url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        completionHandler: @escaping (DataResponse<String>) -> Void
    )
    
}
