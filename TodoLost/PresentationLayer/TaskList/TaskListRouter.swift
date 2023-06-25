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
    func routeTo(target: TaskListRouter.Targets, completion: ((String) -> Void)?)
}

final class TaskListRouter: TaskListRoutingLogic {
    
    private var navigationController: UINavigationController
    
    init(withNavigationController: UINavigationController) {
        navigationController = withNavigationController
    }
    
    /// Таргет для перехода на другой экран
    enum Targets {
        /// Экран с описанием новости и передачей выбранной новости на этот экран
        case taskDetail
    }
    
    func routeTo(target: TaskListRouter.Targets, completion: ((String) -> Void)?) {
        switch target {
        case .taskDetail:
            let taskDetailVC = TaskDetailViewController()
            
            // TODO: На будущее, чтобы колбеком вернуть обновленную модель и вызвать обновление
//            taskDetailVC.completion = completion
            
            PresentationAssembly().colorPicker.config(view: taskDetailVC)
            
            taskDetailVC.modalPresentationStyle = .formSheet
            
            // Получаем текущий контроллер
            guard let currentViewController = navigationController.visibleViewController else {
                SystemLogger.error("Не удалось получить текущий VC")
                return
            }
            
            currentViewController.present(taskDetailVC, animated: true, completion: nil)
        }
    }
}
