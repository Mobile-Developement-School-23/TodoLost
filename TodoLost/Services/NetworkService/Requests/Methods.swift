//
//  Methods.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

enum HttpMethod {
    case get
    case post
    case put
    case delete
    case patch
    
    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        case .patch: return "PATCH"
        }
    }
}
