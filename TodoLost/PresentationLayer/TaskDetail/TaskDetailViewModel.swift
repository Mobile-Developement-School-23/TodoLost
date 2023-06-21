//
//  TaskDetailViewModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 21.06.2023.
//

import Foundation

struct TaskDetailViewModel {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
}
