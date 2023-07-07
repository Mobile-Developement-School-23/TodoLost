import Foundation
import DTLogger

protocol IFileCache {
    var logger: LumberjackLogger? { get set }
    
    var items: [String: TodoItem] { get }
    
    /// Добавляет новый элемент в кеш
    /// - Parameter item: Если ID элемента совпадает, то данные в кеше будут перезаписаны.
    func addToCache(_ item: TodoItem)
    func deleteFromCache(_ itemId: String)
    
    func saveToStorage(jsonFileName: String) throws
    func loadFromStorage(jsonFileName: String) throws
    
    func saveToStorage(csvFileName: String) throws
    func loadFromStorage(csvFileName: String) throws
}

final class FileCache: IFileCache {
    
    static let shared: IFileCache = FileCache()
    var logger: LumberjackLogger?
    
    private(set) var items: [String: TodoItem] = [:]
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    func addToCache(_ item: TodoItem) {
        items[item.id] = item
    }
    
    func deleteFromCache(_ itemId: String) {
        items.removeValue(forKey: itemId)
    }
    
    func saveToStorage(jsonFileName: String) throws {
        guard let fileURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appending(path: "\(jsonFileName).json") else {
            throw FileCacheErrors.failedFoundPath
        }
        
        SystemLogger.info(fileURL.description)
        
        let serializedItems = items.map({ $0.value.json })
        
        do {
            let data = try JSONSerialization.data(withJSONObject: serializedItems)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw FileCacheErrors.failedToSave
        }
    }
    
    func loadFromStorage(jsonFileName: String) throws {
        guard let fileURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appending(path: "\(jsonFileName).json") else {
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
    
    func saveToStorage(csvFileName: String) throws {
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(csvFileName).csv") else {
            throw FileCacheErrors.failedFoundPath
        }
        
        SystemLogger.info(fileURL.description)
        
        var csvString = ""
        
        let serializedItems = items.map({ $0.value.csv })
        guard let firstItem = serializedItems.first else {
            throw FileCacheErrors.failedToSave
        }
        
        let csvRows = firstItem.split(separator: "\n")
        guard csvRows.count > 1 else {
            throw FileCacheErrors.failedToSave
        }
        
        let csvHeader = csvRows[0].components(separatedBy: ",")
        csvString += csvHeader.joined(separator: ",")
        csvString += "\n"
        
        for item in serializedItems {
            let csvRows = item.split(separator: "\n")
            let csvValues = csvRows[1].components(separatedBy: ",")
            
            guard
                let idIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.id),
                let textIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.text),
                let importanceIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.importance),
                let deadlineIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.deadline),
                let isDoneIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.isDone),
                let dateCreatedIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.dateCreated),
                let dateEditedIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.dateEdited)
            else {
                throw FileCacheErrors.invalidIndex
            }
            
            let id = csvValues[idIndex]
            let text = csvValues[textIndex]
            let importance = csvValues[importanceIndex]
            let deadline = csvValues[deadlineIndex]
            let isDone = csvValues[isDoneIndex]
            let dateCreated = csvValues[dateCreatedIndex]
            let dateEdited = csvValues[dateEditedIndex]
            
            csvString += "\(id),\(text),\(importance),\(deadline),\(isDone),\(dateCreated),\(dateEdited)\n"
        }
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw FileCacheErrors.failedToSave
        }
    }
    
    func loadFromStorage(csvFileName: String) throws {
        guard let fileURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("\(csvFileName).csv") else {
            throw FileCacheErrors.failedFoundPath
        }
        
        do {
            let csvData = try String(contentsOf: fileURL)
            
            let csvRows = csvData.components(separatedBy: "\n")
            guard csvRows.count > 1 else {
                throw FileCacheErrors.failedToLoad
            }
            
            // Удаляем первую строку, так как первая строка это
            // заголовки и их не нужно парсить.
            let valueRows = Array(csvRows.dropFirst())
            
            // Забираем заголовок, чтобы в дальнейшем использовать его при парсинге
            let csvHeaderRow = csvRows[0]
            
            for csvRow in valueRows {
                // Проверка на случай пустой строки вместо данных
                if csvRow == "" {
                    logger?.logWarningMessage("Попалась пустая строка")
                    SystemLogger.warning("Попалась пустая строка")
                    continue
                }
                
                // Формируем строку для парсинга добавляя заголовок, это нужно,
                // чтобы даже в случае смены столбцов, индекс ячейки был всё равно правильным
                // и подбирался на основе заголовка
                let itemRows = "\(csvHeaderRow)\n\(csvRow)"
                
                guard let parseItem = TodoItem.parse(csv: itemRows) else {
                    throw FileCacheErrors.failedParse
                }
                
                let todoItem = TodoItem(
                    id: parseItem.id,
                    text: parseItem.text,
                    importance: parseItem.importance,
                    deadline: parseItem.deadline,
                    isDone: parseItem.isDone,
                    dateCreated: parseItem.dateCreated,
                    dateEdited: parseItem.dateEdited
                )
                
                items[parseItem.id] = todoItem
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
        case failedParse
        case invalidData
        case invalidIndex
        
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
            case .invalidData:
                return "Неправильный формат данных"
            case .invalidIndex:
                return "Не удалось найти индекс"
            case .failedParse:
                return "Не удалось распарсить данные"
            }
        }
    }
}
