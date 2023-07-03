//
//  Headers.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation

enum Headers {
    /// Данные для авторизации
    /// - используется Bearer token
    case authorization
    /// Принимает номер ревизии для запроса к серверу на отправку данных.
    /// - Ревизия на сервере должны быть такого же номера, после успешного ответа ревизия увеличивается на 1
    case revision(String?)
    /// Тестовый запрос для проверки поведения на ошибки
    /// - Сервер кидает кубик от 0 до 100 (включительно), если выпало меньше threshold,
    /// возвращает 500-ку, даже если запрос валидный и нормальный
    case generateFails(String?)
    
    var key: String {
        switch self {
        case .authorization:
            return "Authorization"
        case .revision:
            return "X-Last-Known-Revision"
        case .generateFails:
            return "X-Generate-Fails"
        }
    }
    
    var value: String {
        switch self {
        case .authorization:
            return "Bearer \(ConfigurationEnvironment.baseToken)"
        case .revision(let revision):
            guard let revision else { return "0" }
            return revision
        case .generateFails(let number):
            guard let number else { return "50" }
            return number
        }
    }
}
