//
//  URLProvider.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation
import DTLogger

public struct URLProvider {
    public static func getBaseUrl() -> URL {
        guard let url = URL(string: "https://beta.mrdekk.ru/todobackend") else {
            SystemLogger.error("Не удалось преобразовать String в URL")
            fatalError()
        }
        
        return url
    }
}
