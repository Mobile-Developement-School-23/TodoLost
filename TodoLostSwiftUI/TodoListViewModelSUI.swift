//
//  TodoListViewModelSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import Foundation

struct TodoListViewModelSUI: Hashable {
    let id: String
    let dateCreated: Date
    let status: StatusTask
    let title: String
    let subtitle: String?
    
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateEdited: Date?
    let hexColor: String?
    
    static func getModels() -> [TodoListViewModelSUI] {
        [
            TodoListViewModelSUI(
                id: UUID().uuidString,
                dateCreated: Date(),
                status: .statusHigh,
                title: "Погладить кота",
                subtitle: Date.now.toString(format: "dd MMMM"),
                importance: .important,
                deadline: Date.now,
                isDone: false,
                dateEdited: Date(),
                hexColor: nil
            ),
            TodoListViewModelSUI(
                id: UUID().uuidString,
                dateCreated: Date(),
                status: .statusLow,
                title: "Погладить кота, и других котиков, которые придут на мурчание и звуки высыпающегося корма",
                subtitle: Date.now.toString(format: "dd MMMM"),
                importance: .low,
                deadline: Date.now,
                isDone: false,
                dateEdited: Date(),
                hexColor: nil
            ),
            TodoListViewModelSUI(
                id: UUID().uuidString,
                dateCreated: Date(),
                status: .statusDone,
                title: "Погладить кота",
                subtitle: Date.now.toString(format: "dd MMMM"),
                importance: .basic,
                deadline: nil,
                isDone: false,
                dateEdited: Date(),
                hexColor: nil
            ),
            TodoListViewModelSUI(
                id: UUID().uuidString,
                dateCreated: Date(),
                status: .statusDefault,
                title: "Погладить кота",
                subtitle: Date.now.toString(format: "dd MMMM"),
                importance: .basic,
                deadline: nil,
                isDone: false,
                dateEdited: Date(),
                hexColor: nil
            ),
            TodoListViewModelSUI(
                id: UUID().uuidString,
                dateCreated: Date(),
                status: .statusHigh,
                title: "Погладить кота",
                subtitle: Date.now.toString(format: "dd MMMM"),
                importance: .important,
                deadline: Date.distantFuture,
                isDone: false,
                dateEdited: Date(),
                hexColor: nil
            )
        ]
    }
}
