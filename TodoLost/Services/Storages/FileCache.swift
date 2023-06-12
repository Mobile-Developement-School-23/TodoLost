//
//  FileCache.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 12.06.2023.
//

import Foundation

protocol IFileCache {
    var items: [String: TodoItem] { get }
    
    func addToCache(_ item: TodoItem)
    func deleteFromCache(_ itemId: String)
    func saveToStorage(fileName: String) throws
    func loadFromStorage(fileName: String) throws
}

final class FileCache: IFileCache {
    private(set) var items: [String : TodoItem] = [:]
    
    private let fileManager = FileManager.default
    
    func addToCache(_ item: TodoItem) {
        items[item.id] = item
    }
    
    func deleteFromCache(_ itemId: String) {
        items.removeValue(forKey: itemId)
    }
    
    func saveToStorage(fileName: String) throws {
        guard let fileURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appending(path: "\(fileName).json") else {
            throw FileCacheErrors.failedFoundPath
        }
        
        debugPrint(fileURL)
        
        let serializedItems = items.map({ $0.value.json })
        
        do {
            let data = try JSONSerialization.data(withJSONObject: serializedItems)
            try data.write(to: fileURL)
        } catch {
            throw FileCacheErrors.failedToSave
        }
    }
    
    func loadFromStorage(fileName: String) throws {
        guard let fileURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appending(path:"\(fileName).json") else {
            throw FileCacheErrors.failedFoundPath
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            guard let jsonItems = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                throw FileCacheErrors.failedDataConversion
            }
            
            let parsedItems = jsonItems.compactMap { item in
                TodoItem.parse(json: item)
            }
            
            parsedItems.forEach { item in
                items[item.id] = item
            }
        } catch {
            throw FileCacheErrors.failedToLoad
        }
    }
}

extension FileCache {
    enum FileCacheErrors: Error, LocalizedError {
        case failedToSave
        case failedToLoad
        case failedFoundPath
        case failedDataConversion
        
        var errorDescription: String? {
            switch self {
            case .failedToSave:
                return "Не удалось сохранить файл, у меня лапки"
            case .failedToLoad:
                return "Не удалось получить файл, у меня лапки"
            case .failedFoundPath:
                return "Не удалось найти путь"
            case .failedDataConversion:
                return "Не удалось преобразовать полученные из памяти данные"
            }
        }
    }
}
