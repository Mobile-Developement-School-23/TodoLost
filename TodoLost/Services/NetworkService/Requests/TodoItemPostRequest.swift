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
    
    init(data: Data) {
        self.urlRequest = request(data: data)
    }
    
    mutating func request(data: Data) -> URLRequest? {
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
            Headers.postRequest("2").value, // FIXME: Не забыть прокинуть снаружи
            forHTTPHeaderField: Headers.postRequest(nil).value
        )
        urlRequest.httpBody = data
        
        return urlRequest
    }
}
