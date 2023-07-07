//
//  TodoItemPostRequest.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation

struct TodoItemPostRequest: IRequest {
    var urlRequest: URLRequest?
    
    let url: URL = URLProvider.getBaseUrl()
    
    init(data: Data, revision: String) {
        self.urlRequest = request(data: data, revision: revision)
    }
    
    mutating func request(data: Data, revision: String) -> URLRequest? {
        let endpoint = "/list"
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL components")
            return nil
        }
        
        urlComponents.path += endpoint
        
        guard let url = urlComponents.url else {
            print("Invalid complete URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: url, timeoutInterval: 30)
        urlRequest.httpMethod = HttpMethod.post.name
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
