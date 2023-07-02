//
//  NetworkError.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

enum NetworkError: Error {
    case authError
    case messageError(String)
    case serverUnavailable
    case unownedError
    case invalidURL
    case networkError
    case statusCodeError
    case parseError
    case noImage
    
    var describing: String {
        switch self {
        case .authError:
            return "ошибка авторизации"
        case .messageError(let message):
            return message
        case .serverUnavailable:
            return "все упало"
        case .unownedError:
            return "Неизвестная ошибка. До свидания"
        case .invalidURL:
            return "API Error: Неправильно указан URL."
        case .networkError:
            return "Ошибка сети. Попробовать загрузить данные еще раз?"
        case .statusCodeError:
            return "Ошибка получения кода статуса. Обратитесь к разработчику"
        case .parseError:
            return "Ошибка парсинга данных. Обратитесь к разработчику"
        case .noImage:
            return "По ссылке не найдено изображение"
        }
    }
}
