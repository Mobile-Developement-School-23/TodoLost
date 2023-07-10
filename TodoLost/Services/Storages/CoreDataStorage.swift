//
//  CoreDataStorage.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 10.07.2023.
//

import CoreData
import DTLogger

/// Протокол для работы с базой данных
protocol ICoreDataStorage {
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void, completion: @escaping () -> Void)
    
    /// Метод для сохранения объекта
    /// - В случае совпадения id, объект перезаписывается.
    /// - Parameters:
    ///   - task: <#task description#>
    ///   - context: принимает контекст, в котором производится работа с данными.
    func save(_ task: TodoItem, context: NSManagedObjectContext)
    
    /// Метод для получения всех объектов из CoreData в контексте для чтения
    /// - Returns: <#description#>
    func fetchObjects() throws -> [DBTodoItem]
    
    /// Метод для получения объекта по ID в текущем контексте
    /// - tip: Используется в случае необходимости работы с объектами в одном контексте.
    /// - Так же используется для удаления объекта из базы в методе deleteObject(withId:)
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - context: принимает контекст, в котором производится работа с данными.
    /// - Returns: <#description#>
    func fetchObject(withId id: String, context: NSManagedObjectContext) -> DBTodoItem?
    
    /// Метод для получения объекта по ID
    /// - Использует контекст для чтения
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func fetchObject(withId id: String) -> DBTodoItem?
    
    /// Метод для удаления объекта, который был получен в текущем контексте
    /// - Parameters:
    ///   - currentObject: <#currentObject description#>
    ///   - context: принимает контекст, в котором производится работа с данными.
    func delete(_ currentObject: NSManagedObject, context: NSManagedObjectContext)
    
    /// Метод для удаления объекта по ID
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - context: принимает контекст, в котором производится работа с данными.
    func deleteObject(withId id: String, context: NSManagedObjectContext)
}
 
final class CoreDataStorage {
    static let shared = CoreDataStorage()
    
    // MARK: - Core Data stack
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoItem")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                SystemLogger.error("\(error)")
            } else {
                SystemLogger.info("\(storeDescription)")
            }
        }
        return container
    }()
    
    private lazy var readContext: NSManagedObjectContext = {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private lazy var writeContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()
    
    private init() {}
}

// MARK: - CRUD

extension CoreDataStorage: ICoreDataStorage {
    func save(_ task: TodoItem, context: NSManagedObjectContext) {
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: DBTodoItem.self),
            into: context
        )
        
        guard let dbObject = managedObject as? DBTodoItem else {
            SystemLogger.error("Ошибка каста до DBTodoItem")
            return
        }
        
        dbObject.id = task.id
        dbObject.text = task.text
        dbObject.importance = task.importance.rawValue
        dbObject.deadline = task.deadline
        dbObject.isDone = task.isDone
        dbObject.dateCreated = task.dateCreated
        dbObject.dateEdited = task.dateEdited
        dbObject.hexColor = task.hexColor
        
        SystemLogger.info("Запуск сохранения объекта \(dbObject.id ?? "no id")")
    }
    
    func fetchObjects() throws -> [DBTodoItem] {
        let fetchRequest: NSFetchRequest<DBTodoItem> = DBTodoItem.fetchRequest()
        let dbObjects = try readContext.fetch(fetchRequest)
        return dbObjects
    }
    
    func fetchObject(withId id: String, context: NSManagedObjectContext) -> DBTodoItem? {
        let fetchRequest: NSFetchRequest<DBTodoItem> = DBTodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            SystemLogger.info("Объект получен из базы. ID: \(results.first?.id ?? "")")
            return results.first
        } catch {
            SystemLogger.error("Не удалось получить объект. Ошибка: \(error)")
            return nil
        }
    }
    
    func fetchObject(withId id: String) -> DBTodoItem? {
        let fetchRequest: NSFetchRequest<DBTodoItem> = DBTodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try readContext.fetch(fetchRequest)
            SystemLogger.info("Объект получен из базы. ID: \(results.first?.id ?? "")")
            return results.first
        } catch {
            SystemLogger.error("Не удалось получить объект. Ошибка: \(error)")
            return nil
        }
    }
    
    func delete(_ currentObject: NSManagedObject, context: NSManagedObjectContext) {
        let objectID = currentObject.objectID
        let currentObject = context.object(with: objectID)
        context.delete(currentObject)

        SystemLogger.info("Запуск удаления объекта из базы")
    }
    
    func deleteObject(withId id: String, context: NSManagedObjectContext) {
        if let object = fetchObject(withId: id, context: context) {
            context.delete(object)
            SystemLogger.info("Запуск удаления объекта с id: \(id)")
        } else {
            SystemLogger.info("Объект с id \(id) не найден")
        }
    }
    
    // MARK: - Save context
    
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void, completion: @escaping () -> Void) {
        let context = writeContext
        context.perform { [weak self] in
            block(context)
            SystemLogger.info("Проверка контекста на изменение")
            if context.hasChanges {
                SystemLogger.info("Данные изменены, попытка сохранения")
                do {
                    try self?.performSave(in: context) {
                        completion()
                    }
                } catch {
                    SystemLogger.error(error.localizedDescription)
                }
            } else {
                SystemLogger.info("Изменений нет")
            }
            
            SystemLogger.info("Проверка контекста на изменение закончена")
        }
    }
    
    private func performSave(in context: NSManagedObjectContext, completion: () -> Void) throws {
        try context.save()
        completion()
        SystemLogger.info("Данные сохранены")
    }
}
