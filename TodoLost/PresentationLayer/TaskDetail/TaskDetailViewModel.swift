//
//  TaskDetailViewModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 21.06.2023.
//

import UIKit

struct TaskDetailViewModel {
    var id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    /// Используется при переключении свича, чтобы вернуть дату и не сохранить nil, если пользователь
    /// решил в начале отключить а затем обратно включить дедлайн
    var tempDeadline: Date?
    var dateCreated: Date
    var textColor: UIColor? = Colors.labelPrimary
    var isDone: Bool
}
