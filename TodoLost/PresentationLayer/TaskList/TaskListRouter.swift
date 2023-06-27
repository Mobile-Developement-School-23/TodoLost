//
//  TaskListRouter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import Foundation

import UIKit
import DTLogger

/// Протокол логики роутера
protocol TaskListRoutingLogic {
    /// Переход к определенному экрану по таргету
    /// - Parameters:
    ///   - target: таргет экрана, на который будет осуществлен переход
    ///   - completion: <#completion description#>
    func routeTo(target: TaskListRouter.Targets, completion: (() -> Void)?)
}

final class TaskListRouter: TaskListRoutingLogic {
    
    private var navigationController: UINavigationController
    
    init(withNavigationController: UINavigationController) {
        navigationController = withNavigationController
    }
    
    /// Таргет для перехода на другой экран
    enum Targets {
        /// Экран с описанием новости и передачей выбранной новости на этот экран
        ///  - принимает ID модели, для того чтобы по этому ID бала найдена задача в кеше,
        ///  и следующий экран октрыл правильную. Если id нет, будет открыт экран для создания
        ///  новой задачи.
        case taskDetail(String?)
    }
    
    func routeTo(target: TaskListRouter.Targets, completion: (() -> Void)?) {
        switch target {
        case .taskDetail(let itemID):
            let taskDetailVC = TaskDetailViewController()
            
            PresentationAssembly().taskDetail.config(
                view: taskDetailVC,
                navigationController: navigationController
            )
            
            taskDetailVC.presenter?.completion = completion
            taskDetailVC.presenter?.itemID = itemID
            
            taskDetailVC.modalPresentationStyle = .formSheet
            let nextNavigationController = UINavigationController(
                rootViewController: taskDetailVC
            )
            
            navigationController.present(nextNavigationController, animated: true, completion: nil)
        }
    }
}
