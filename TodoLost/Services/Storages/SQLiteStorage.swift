//
//  SQLiteStorage.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 08.07.2023.
//

import Foundation
import SQLite
import DTLogger

protocol ISQLiteStorage {
    /// Метод для создания базы данных
    /// - Если база уже была создана, просто соединится с файлом базы для дальнейшей работы
    func fetchOrCreateDB() throws
    
    func insertOrReplace(item: TodoItem) throws
    func load() throws -> [TodoItem]?
    func loadItem(id: String) throws -> TodoItem?
    func delete(id: String) throws
}

final class SQLiteStorage {
    private let fileManager = FileManager.default
    
    private var db: Connection?
    
    private let tableDB = Table("items")
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importance = Expression<String>("importance")
    private let deadline = Expression<Date?>("deadline")
    private let isDone = Expression<Bool>("isDone")
    private let dateCreated = Expression<Date>("dateCreated")
    private let dateEdited = Expression<Date?>("dateEdited")
    private let hexColor = Expression<String?>("hexColor")
}

// MARK: - ISQLiteStorage

extension SQLiteStorage: ISQLiteStorage {
    func fetchOrCreateDB() throws {
        guard let fileURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appending(path: "db.sqlite") else {
            throw Errors.failedFoundPath
        }
        
        db = try? Connection(fileURL.path)
        
        db?.trace { SystemLogger.info($0) }
        
        do {
            try db?.run(tableDB.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(text)
                table.column(importance)
                table.column(deadline)
                table.column(isDone)
                table.column(dateCreated)
                table.column(dateEdited)
                table.column(hexColor)
            })
        } catch {
            throw Errors.failedCreateDB(error.localizedDescription)
        }
    }
    
    func insertOrReplace(item: TodoItem) throws {
        let insertOrReplace = tableDB.insert(
            or: .replace,
            id <- item.id,
            text <- item.text,
            importance <- item.importance.rawValue,
            deadline <- item.deadline,
            isDone <- item.isDone,
            dateCreated <- item.dateCreated,
            dateEdited <- item.dateEdited,
            hexColor <- item.hexColor
        )
        
        do {
            try db?.run(insertOrReplace)
        } catch {
            throw Errors.failedToSave(error.localizedDescription)
        }
    }
    
    func load() throws -> [TodoItem]? {
        var items: [TodoItem] = []
        
        do {
            let query = tableDB.select(*)
            
            guard let result = try db?.prepare(query) else { return nil }
            
            for row in result {
                let item = TodoItem(
                    id: row[id],
                    text: row[text],
                    importance: Importance(rawValue: row[importance]) ?? .basic,
                    deadline: row[deadline],
                    isDone: row[isDone],
                    dateCreated: row[dateCreated],
                    dateEdited: row[dateEdited],
                    hexColor: row[hexColor]
                )
                
                items.append(item)
            }
        } catch {
            throw Errors.failedToLoad(error.localizedDescription)
        }
        
        return items
    }
    
    func loadItem(id: String) throws -> TodoItem? {
        var item: TodoItem?
        
        let query = tableDB.filter(id == self.id)
        
        do {
            if let row = try db?.pluck(query) {
                item = TodoItem(
                    id: row[self.id],
                    text: row[text],
                    importance: Importance(rawValue: row[importance]) ?? .basic,
                    deadline: row[deadline],
                    isDone: row[isDone],
                    dateCreated: row[dateCreated],
                    dateEdited: row[dateEdited],
                    hexColor: row[hexColor]
                )
            }
        } catch {
            throw Errors.failedToLoad(error.localizedDescription)
        }
        
        return item
    }
    
    func delete(id: String) throws {
        let deleteQuery = tableDB.filter(id == self.id).delete()
        
        do {
            try db?.run(deleteQuery)
        } catch {
            throw Errors.failedDelete(error.localizedDescription)
        }
    }
}

// MARK: - Errors

extension SQLiteStorage {
    enum Errors: Error, LocalizedError {
        case failedCreateDB(String)
        case failedToSave(String)
        case failedToLoad(String)
        case failedDelete(String)
        case failedFoundPath
        
        var errorDescription: String? {
            switch self {
            case .failedCreateDB(let message): return message
            case .failedToSave(let message): return message
            case .failedToLoad(let message): return message
            case .failedDelete(let message): return message
            case .failedFoundPath: return "Не удалось найти путь"
            }
        }
    }
}
