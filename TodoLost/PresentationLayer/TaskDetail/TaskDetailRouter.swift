//
//  TaskDetailRouter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 23.06.2023.
//

import UIKit
import DTLogger

/// Протокол логики роутера
protocol TaskDetailRoutingLogic {
    /// Переход к определенному экрану по таргету
    /// - Parameter target: таргет экрана, на который будет осуществлен переход
    func routeTo(target: TaskDetailRouter.Targets, completion: ((String) -> Void)?)
}

final class TaskDetailRouter: TaskDetailRoutingLogic {
    
    private var navigationController: UINavigationController
    
    init(withNavigationController: UINavigationController) {
        navigationController = withNavigationController
    }
    
    /// Таргет для перехода на другой экран
    enum Targets {
        /// Экран с описанием новости и передачей выбранной новости на этот экран
        case colorPicker
    }
    
    func routeTo(target: TaskDetailRouter.Targets, completion: ((String) -> Void)?) {
        switch target {
        case .colorPicker:
            let colorPickerVC = ColorPickerViewController()
            colorPickerVC.completion = completion
            colorPickerVC.modalPresentationStyle = .formSheet
            PresentationAssembly().colorPicker.config(view: colorPickerVC)
            
            guard let currentViewController = navigationController.visibleViewController else {
                SystemLogger.error("Не удалось получить текущий VC")
                return
            }
            
            currentViewController.navigationController?.pushViewController(colorPickerVC, animated: true)
        }
    }
}
