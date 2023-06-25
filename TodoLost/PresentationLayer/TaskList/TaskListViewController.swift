//
//  TaskListViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

/// Протокол отображения данных ViewCintroller-a
protocol TaskListView: AnyObject {
    
}

final class TaskListViewController: UIViewController {
    
    // MARK: - Public property
    
    var presenter: TaskListPresenter?
    
    // MARK: - Private property
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Actions
    
}

// MARK: - Логика обновления данных View

extension TaskListViewController: TaskListView {
    
}

// MARK: - Конфигурирование ViewController

private extension TaskListViewController {
    func setup() {
        view.backgroundColor = .blue
    }
}
