//
//  TaskModel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

struct TaskViewModel: Hashable {
    let id: String
    let dateCreated: Date
    let status: StatusTask
    let title: String
    let subtitle: String?
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
