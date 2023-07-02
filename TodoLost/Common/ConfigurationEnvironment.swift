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
            #warning("Для проверки работы, подставь в return свой токен")
            // Токен был вынесен в отдельный конфиг, чтобы он не попал на гитхаб
            return ""
        }
        return environment
    }()
}
