//
//  TaskListConfigurator.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

/// Конфигурация MVP модуля
final class TaskListConfigurator {
    private let fileCacheStorage: IFileCache
    private let splashScreenPresenter: ISplashScreenPresenter
    
    init(
        fileCacheStorage: IFileCache,
        splashScreenPresenter: ISplashScreenPresenter
    ) {
        self.fileCacheStorage = fileCacheStorage
        self.splashScreenPresenter = splashScreenPresenter
    }
    
    func config(
        view: UIViewController,
        navigationController: UINavigationController
    ) {
        guard let view = view as? TaskListViewController else { return }
        let presenter = TaskListPresenter(view: view)
        let dataSourceProvider: ITaskListDataSourceProvider = TaskListDataSourceProvider(presenter: presenter)
        let router = TaskListRouter(withNavigationController: navigationController)
        
        view.presenter = presenter
        view.dataSourceProvider = dataSourceProvider
        view.splashScreenPresenter = splashScreenPresenter
        presenter.view = view
        presenter.router = router
        presenter.fileCacheStorage = fileCacheStorage
    }
}
