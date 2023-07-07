//
//  TodoItemGetRequest.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 03.07.2023.
//

import Foundation

struct TodoItemGetRequest: IRequest {
    var urlRequest: URLRequest?
    
    let url: URL = URLProvider.getBaseUrl()
    
    init(id: String, revision: String) {
        self.urlRequest = request(id: id, revision: revision)
    }
    
    mutating func request(id: String, revision: String) -> URLRequest? {
        let endpoint = "/list"
        let id = "/\(id)"
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL components")
            return nil
        }
        
        urlComponents.path += endpoint
        urlComponents.path += id
        
        guard let url = urlComponents.url else {
            print("Invalid complete URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: url, timeoutInterval: 30)
        urlRequest.httpMethod = HttpMethod.get.name
        urlRequest.addValue(
            Headers.authorization.value,
            forHTTPHeaderField: Headers.authorization.key
        )
        
        return urlRequest
    }
}
