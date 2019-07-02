//
//  NetworkService.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    
    // singleton
    private init() {}
    
    var alamofireWrapper: AlamofireProtocol?
    
    private let verbose = true
    
    private func verbosePrint(_ msg: String) {
        if verbose {
            print(msg)
        }
    }
    
    //privateKey=1d588981a69ac0e029babffd9b44d7aad2063896
    //noMD5hash=15620445751d588981a69ac0e029babffd9b44d7aad20638968ab74ba1c1207e5f0c2af5e66da8d94b
    var apiKeyTsHash: String {
        get {
            let apikey = "8ab74ba1c1207e5f0c2af5e66da8d94b"
            let ts = "1562044575"
            let hash = "6bcfec4f7e4ab315829b28358cb2d313"
            return "apikey=\(apikey)&ts=\(ts)&hash=\(hash)"
        }
    }
    
    var baseUrl: String {
        get {
            return "https://gateway.marvel.com/v1/public/"
        }
    }
    
    private func treatError(url: String, response: DataResponse<String>) -> String{
        print("treatError - NetworkService")
        verbosePrint("error=\(response.description)")
        if let localizedDescription = response.result.error?.localizedDescription {
            return localizedDescription
        } else if response.result.debugDescription.count > 0 {
            return response.result.debugDescription
        }
        return "error: \(response.response?.statusCode ?? 0)"
    }
    
    func request(
        url: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        complete: @escaping ( ServiceResult<String?> ) -> Void )
    {
        print("request - NetworkService")
        guard let wrapper = alamofireWrapper else {
            return complete(.Error("Error creating request", 0))
        }
        
        wrapper.responseString(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
        { [weak self] response in
            self?.verbosePrint("url=\(response.request?.url?.description ?? "")")
            let statusCode = response.response?.statusCode ?? -1
            self?.verbosePrint("status code=\(statusCode)")
            if response.result.isSuccess {
                print("response.result.isSuccess")
                return complete(.Success(response.result.value, statusCode))
                
            }
            return complete(.Error(self?.treatError(url: url, response: response) ?? "", response.response?.statusCode))
        }
        
    }
}
