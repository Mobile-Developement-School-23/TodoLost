//
//  TaskListConfigurator.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

/// Конфигурация MVP модуля
final class TaskListConfigurator {
    func config(
        view: UIViewController,
        navigationController: UINavigationController
    ) {
        guard let view = view as? TaskListViewController else { return }
        let presenter = TaskListPresenter(view: view)
        let router = TaskListRouter(withNavigationController: navigationController)
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
    }
}
