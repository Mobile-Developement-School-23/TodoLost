//
//  TodoItemPutRequest.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 03.07.2023.
//

import Foundation

struct TodoItemPutRequest: IRequest {
    var urlRequest: URLRequest?
    
    let url: URL = URLProvider.getBaseUrl()
    
    init(data: Data, id: String, revision: String) {
        self.urlRequest = request(data: data, id: id, revision: revision)
    }
    
    mutating func request(data: Data, id: String, revision: String) -> URLRequest? {
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
        urlRequest.httpMethod = HttpMethod.put.name
        urlRequest.addValue(
            Headers.authorization.value,
            forHTTPHeaderField: Headers.authorization.key
        )
        urlRequest.addValue(
            Headers.revision(revision).value,
            forHTTPHeaderField: Headers.revision(nil).key
        )
        urlRequest.httpBody = data
        
        return urlRequest
    }
}
