//
//  TodoListModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import UIKit

struct APIListResponse: Codable {
    let status: String
    let list: [TodoItemServerModel]
    let revision: Int
    
    init(
        status: String = "",
        list: [TodoItemServerModel],
        revision: Int = 0
    ) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}

struct APIElementResponse: Codable {
    let status: String
    let element: TodoItemServerModel
    let revision: Int
    
    init(
        status: String = "",
        element: TodoItemServerModel,
        revision: Int = 0
    ) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}

struct TodoItemServerModel: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: String
}

// MARK: - TodoItem to APIElementResponse

extension APIElementResponse {
    /// Метод для конвертации при отправке или обновлении задачи на сервере
    /// - Parameter task: <#task description#>
    /// - Returns: <#description#>
    /// - warning: При конвертации присваивается текущая дата изменения.
    static func convert(_ task: TodoItem) -> APIElementResponse {
        var deadlineInt: Int64?
        if let deadline = task.deadline?.timeIntervalSince1970 {
            deadlineInt = Int64(deadline)
        }
        
        let dateCreated = Int64(task.dateCreated.timeIntervalSince1970)
        
        let model = APIElementResponse(
            element: TodoItemServerModel(
                id: task.id,
                text: task.text,
                importance: task.importance.rawValue,
                deadline: deadlineInt,
                done: task.isDone,
                color: task.hexColor,
                createdAt: dateCreated,
                changedAt: Int64(Date.now.timeIntervalSince1970),
                lastUpdatedBy: UIDevice.current.name
            )
        )
        
        return model
    }
}

// MARK: - [TaskViewModel] to APIListResponse

extension APIListResponse {
    /// Метод для конвертации  списка дел при отправке обновления на сервер
    /// - Parameter tasks: <#tasks description#>
    /// - Returns: <#description#>
    static func convert(_ tasks: [TaskViewModel]) -> APIListResponse {
        var items: [TodoItemServerModel] = []
        
        tasks.forEach { task in
            var deadlineInt: Int64?
            if let deadline = task.deadline?.timeIntervalSince1970 {
                deadlineInt = Int64(deadline)
            }
            
            let dateCreated = Int64(task.dateCreated.timeIntervalSince1970)
            var dateEditedInt = dateCreated
            if let dateEdited = task.dateEdited?.timeIntervalSince1970 {
                dateEditedInt = Int64(dateEdited)
            }
            
            let item = TodoItemServerModel(
                id: task.id,
                text: task.title,
                importance: task.importance.rawValue,
                deadline: deadlineInt,
                done: task.isDone,
                color: task.hexColor,
                createdAt: dateCreated,
                changedAt: dateEditedInt,
                lastUpdatedBy: UIDevice.current.name
            )
            
            items.append(item)
        }
        
        let model = APIListResponse(
            status: "",
            list: items,
            revision: 0
        )
        
        return model
    }
}

// MARK: - APIListResponse to TodoItem

extension APIListResponse {
    /// Метод для конвертации полученных данных с сервера
    /// - Parameter serverModels: <#serverModels description#>
    /// - Returns: <#description#>
    /// - Используется при получении серверной модели перед сохранением данных в память устройства
    static func convert(_ serverModels: APIListResponse) -> [TodoItem] {
        var todoItems: [TodoItem] = []
        
        serverModels.list.forEach { model in
            
            let deadlineTimestamp = Double(model.createdAt) as TimeInterval
            let dateCreated = Date(timeIntervalSince1970: deadlineTimestamp)
            
            var deadline: Date?
            if let deadlineInt = model.deadline {
                let deadlineTimestamp = Double(deadlineInt) as TimeInterval
                deadline = Date(timeIntervalSince1970: deadlineTimestamp)
            }
            
            let dateEditedTimestamp = Double(model.changedAt) as TimeInterval
            let dateEdited = Date(timeIntervalSince1970: dateEditedTimestamp)
            
            let item = TodoItem(
                id: model.id,
                text: model.text,
                importance: Importance(rawValue: model.importance) ?? .basic,
                deadline: deadline,
                isDone: model.done,
                dateCreated: dateCreated,
                dateEdited: dateEdited,
                hexColor: model.color
            )
            
            todoItems.append(item)
        }
        
        return todoItems
    }
}
