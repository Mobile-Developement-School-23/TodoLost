//
//  TaskDetailViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit

/// Протокол отображения данных ViewCintroller-a
protocol TaskDetailView: AnyObject {
    
}

final class TaskDetailViewController: UIViewController {
    
    // MARK: - Public property
    
    var presenter: TaskDetailPresenter?
    
    // MARK: - Private property
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Actions
    
}

// MARK: - Логика обновления данных View

extension TaskDetailViewController: TaskDetailView {
    
}

// MARK: - Конфигурирование ViewController

private extension TaskDetailViewController {
    /// Метод инициализации VC
    func setup() {
        view.backgroundColor = .cyan
        title = "Дело"
    }
}
