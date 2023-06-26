//
//  TaskListPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import Foundation

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskListPresentationLogic: AnyObject {
    init(view: TaskListView)
    func getModels()
}

final class TaskListPresenter {
    // MARK: - Public Properties
    
    weak var view: TaskListView?
    var router: TaskListRoutingLogic?
    
    // MARK: - Private properties
    
    // MARK: - Initializer
    
    required init(view: TaskListView) {
        self.view = view
    }
}

// MARK: - Presentation Logic

extension TaskListPresenter: TaskListPresentationLogic {
    func getModels() {
        var models: [TaskViewModel] = []
        
        for id in 0...15 {
            models.append(TaskViewModel(id: "ID: \(id)"))
        }
        
        view?.display(models: models)
    }
}
