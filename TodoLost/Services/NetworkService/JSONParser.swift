//
//  TodoParser.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation
import DTLogger

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
    func parse(model: Model) -> Data
}

final class JSONParser<Model: Codable>: IParser {
    func parse(model: Model) -> Data {
        var data: Data = Data()
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            data = try encoder.encode(model)
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        return data
    }
    
    func parse(data: Data) -> Model? {
        var model: Model?
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            model = try decoder.decode(Model.self, from: data)
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        return model
    }
}
