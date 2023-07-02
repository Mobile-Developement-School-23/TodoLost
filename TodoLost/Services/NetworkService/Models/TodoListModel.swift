//
//  TodoListModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

struct ListItem: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let color: String?
    let createdAt: Int
    let changedAt: Int
    let lastUpdatedBy: String

    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

struct APIResponse: Codable {
    let status: String
    let list: [ListItem]
    let revision: Int
}
