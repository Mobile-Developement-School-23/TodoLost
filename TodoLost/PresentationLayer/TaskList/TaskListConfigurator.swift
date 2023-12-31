//
//  TaskListConfigurator.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

/// Конфигурация MVP модуля
final class TaskListConfigurator {
    private let logger: LumberjackLogger
    private let fileCacheStorage: IFileCache
    private let sqliteStorage: ISQLiteStorage
    private let splashScreenPresenter: ISplashScreenPresenter
    private let networkManager: INetworkManager
    private let coreDataStorage: ICoreDataStorage
    
    init(
        logger: LumberjackLogger,
        fileCacheStorage: IFileCache,
        sqliteStorage: ISQLiteStorage,
        coreDataStorage: ICoreDataStorage,
        splashScreenPresenter: ISplashScreenPresenter,
        networkManager: INetworkManager
    ) {
        self.logger = logger
        self.fileCacheStorage = fileCacheStorage
        self.sqliteStorage = sqliteStorage
        self.coreDataStorage = coreDataStorage
        self.splashScreenPresenter = splashScreenPresenter
        self.networkManager = networkManager
    }
    
    func config(
        view: UIViewController,
        navigationController: UINavigationController
    ) {
        guard let view = view as? TaskListViewController else { return }
        let presenter = TaskListPresenter(view: view)
        let dataSourceProvider: ITaskListDataSourceProvider = TaskListDataSourceProvider(presenter: presenter)
        let router = TaskListRouter(
            withNavigationController: navigationController,
            networkManager: networkManager
        )
        let transitionAnimation = TransitionAnimationVC()
        
        view.presenter = presenter
        view.dataSourceProvider = dataSourceProvider
        view.splashScreenPresenter = splashScreenPresenter
        view.transition = transitionAnimation
        presenter.view = view
        presenter.router = router
        presenter.logger = logger
        presenter.fileCacheStorage = fileCacheStorage
        presenter.sqliteStorage = sqliteStorage
        presenter.coreDataStorage = coreDataStorage
        presenter.networkManager = networkManager
    }
}
