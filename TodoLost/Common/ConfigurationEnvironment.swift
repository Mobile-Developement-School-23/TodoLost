//
//  ConfigurationEnvironment.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation
import DTLogger

struct ConfigurationEnvironment {
    enum Keys {
        static let baseToken = "baseToken"
    }
    
    static let baseToken: String = {
        guard let environment = Bundle.main.object(
            forInfoDictionaryKey: Keys.baseToken
        ) as? String else {
            SystemLogger.error("Не удалось получить токен к серверу из конфигурации")
            #warning("Для проверки работы, подставь в return свой токен вместо пустой строки")
            // Токен был вынесен в отдельный конфиг, чтобы он не попал на гитхаб
            // Если что-то будет отображаться красным файлом, это оно. Так и должно быть :)
            return ""
        }
        return environment
    }()
}
