//
//  AlamofireWrapper.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//


import Foundation
import Alamofire

class AlamofireWrapper: AlamofireProtocol {
    
    var manager: Alamofire.SessionManager
    
    init() {
        print("init - AlamofireWrapper")
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "gateway.marvel.com": .disableEvaluation
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
    
    func responseString(
        _ url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        completionHandler: @escaping (DataResponse<String>) -> Void
        ) {
        print("responseString - AlamofireWrapper")
        manager.request(url, method: method, parameters: parameters, encoding: encoding).responseString(completionHandler: completionHandler)
    }
    
}
