//
//  TodoParser.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation
import DTLogger

final class TodoListParser<Model: Decodable>: IParser {
    func parse(data: Data) -> Model? {
        var model: Model?
        
        do {
            model = try JSONDecoder().decode(Model.self, from: data)
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        return model
    }
}

struct TodoListGetRequest: IRequest {
    var urlRequest: URLRequest?
    
    let url: URL = URLProvider.getBaseUrl()
    let method: HttpMethod = .get
    var header: Header {
        return Header(
            key: "Authorization",
            value: ConfigurationEnvironment.baseToken
        )
    }
    
    init() {
        self.urlRequest = request()
    }
    
    mutating func request() -> URLRequest? {
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
        urlRequest.httpMethod = method.name
        urlRequest.addValue("Bearer \(header.value)", forHTTPHeaderField: header.key)
        
        return urlRequest
    }
}

struct Header {
    let key: String
    let value: String
}

enum HttpMethod {
    case get
    case post
    
    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}
