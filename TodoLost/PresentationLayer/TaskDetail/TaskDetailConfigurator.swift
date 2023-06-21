//
//  TaskDetailConfigurator.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit

/// Конфигурация MVP модуля
final class TaskDetailConfigurator {
    private let fileCacheStorage: IFileCache
    
    init(fileCacheStorage: IFileCache) {
        self.fileCacheStorage = fileCacheStorage
    }
    
    func config(
        view: UIViewController
    ) {
        guard let view = view as? TaskDetailViewController else { return }
        let presenter = TaskDetailPresenter(view: view)
        
        view.presenter = presenter
        presenter.view = view
        presenter.fileCacheStorage = fileCacheStorage
    }
}
