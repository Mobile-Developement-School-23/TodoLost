//
//  TaskModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

struct TaskViewModel: Hashable {
    let id: String
    let status: StatusTask
    let title: String
    let subtitle: String?
    
    static func demoTasks() -> [TaskViewModel] {
        [
            TaskViewModel(
                id: UUID().uuidString,
                status: .statusDefault,
                title: "Купить хлеб",
                subtitle: Date().toString(format: "dd MMMM")
            ),
            TaskViewModel(
                id: UUID().uuidString,
                status: .statusDone,
                title: "Купить хлеб",
                subtitle: Date().toString(format: "dd MMMM")
            ),
            TaskViewModel(
                id: UUID().uuidString,
                status: .statusHigh,
                title: "Погладить кода",
                subtitle: Date().toString(format: "dd MMMM")
            ),
            TaskViewModel(
                id: UUID().uuidString,
                status: .statusDefault,
                title: "Задачу у которой будет очень много рандомного текста дл]орпав вплыаывп ыдупк вап ывоарпфудкрп лоавпыва ывдалорфпз гп аволпыдрла пыдлваоп ",
                subtitle: Date().toString(format: "dd MMMM")
            ),
            TaskViewModel(
                id: UUID().uuidString,
                status: .statusDefault,
                title: "Купить хлеб",
                subtitle: nil
            ),
            TaskViewModel(
                id: UUID().uuidString,
                status: .statusLow,
                title: "Купить хлеб",
                subtitle: nil
            )
        ]
    }
}

enum StatusTask {
    case statusDefault
    case statusHigh
    case statusLow
    case statusDone
    
    var imageStatus: UIImage? {
        switch self {
        case .statusDefault: return Icons.statusDefault.image
        case .statusHigh: return Icons.statusHigh.image
        case .statusDone: return Icons.statusDone.image
        case .statusLow: return Icons.statusDefault.image
        }
    }
}
