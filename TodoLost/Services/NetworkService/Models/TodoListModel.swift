//
//  TodoListModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

struct APIListResponse: Codable {
    let status: String
    let list: [TodoItemServerModel]
    let revision: Int
}

struct APIElementResponse: Codable {
    let element: TodoItemServerModel
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
