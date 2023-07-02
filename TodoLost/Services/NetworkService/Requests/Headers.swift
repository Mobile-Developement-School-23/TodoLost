//
//  Headers.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation

struct Header {
    let key: String
    let value: String
}

enum Headers {
    case authorization
    /// Принимает номер ревизии для запроса к серверу на отправку данных.
    /// - Ревизия на сервере должны быть такого же номера, после успешного ответа ревизия увеличивается на 1
    case postRequest(String?)
    
    var key: String {
        switch self {
        case .authorization:
            return "Authorization"
        case .postRequest:
            return "X-Last-Known-Revision"
        }
    }
    
    var value: String {
        switch self {
        case .authorization:
            return "Bearer \(ConfigurationEnvironment.baseToken)"
        case .postRequest(let revision):
            guard let revision else { return "0"}
            return revision
        }
    }
}
