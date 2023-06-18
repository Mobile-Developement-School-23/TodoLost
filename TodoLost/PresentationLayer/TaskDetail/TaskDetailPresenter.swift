//
//  TaskDetailPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import Foundation

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskDetailPresentationLogic: AnyObject {
    init(view: TaskDetailView)
}

final class TaskDetailPresenter {
    // MARK: - Public Properties
    
    weak var view: TaskDetailView?
    
    // MARK: - Private properties
    
    // MARK: - Initializer
    
    required init(view: TaskDetailView) {
        self.view = view
    }
}

// MARK: - Presentation Logic

extension TaskDetailPresenter: TaskDetailPresentationLogic {
    
}
