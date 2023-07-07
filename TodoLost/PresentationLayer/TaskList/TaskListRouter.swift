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
    func routeTo(
        target: TaskListRouter.Targets,
        completion: (() -> Void)?,
        cancelCompletion: (() -> Void)?
    )
}

final class TaskListRouter: TaskListRoutingLogic {
    
    private var navigationController: UINavigationController
    private var networkManager: INetworkManager
    
    init(
        withNavigationController: UINavigationController,
        networkManager: INetworkManager
    ) {
        navigationController = withNavigationController
        self.networkManager = networkManager
    }
    
    /// Таргет для перехода на другой экран
    enum Targets {
        /// Экран с описанием новости и передачей выбранной новости на этот экран
        ///  - принимает ID модели, для того чтобы по этому ID бала найдена задача в кеше,
        ///  и следующий экран октрыл правильную. Если id нет, будет открыт экран для создания
        ///  новой задачи.
        case taskDetail(String?)
    }
    
    func routeTo(
        target: TaskListRouter.Targets,
        completion: (() -> Void)?,
        cancelCompletion: (() -> Void)?
    ) {
        switch target {
        case .taskDetail(let itemID):
            let taskDetailVC = TaskDetailViewController()
            
            PresentationAssembly().taskDetail.config(
                view: taskDetailVC,
                navigationController: navigationController,
                networkManager: networkManager,
                itemID: itemID,
                completion: completion,
                cancelCompletion: cancelCompletion
            )
            
            guard let currentViewController = navigationController.visibleViewController else {
                SystemLogger.error("Не удалось получить текущий VC")
                return
            }
            
            let nextNavigationController = UINavigationController(
                rootViewController: taskDetailVC
            )
            
            nextNavigationController.transitioningDelegate = currentViewController as? TaskListViewController
            
            navigationController.present(nextNavigationController, animated: true, completion: nil)
        }
    }
}
