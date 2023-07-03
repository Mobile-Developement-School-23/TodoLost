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
    private let requestService: IRequestSender
    private let splashScreenPresenter: ISplashScreenPresenter
    
    init(
        logger: LumberjackLogger,
        fileCacheStorage: IFileCache,
        requestService: IRequestSender,
        splashScreenPresenter: ISplashScreenPresenter
    ) {
        self.logger = logger
        self.fileCacheStorage = fileCacheStorage
        self.requestService = requestService
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
        let transitionAnimation = TransitionAnimationVC()
        
        view.presenter = presenter
        view.dataSourceProvider = dataSourceProvider
        view.splashScreenPresenter = splashScreenPresenter
        view.transition = transitionAnimation
        presenter.view = view
        presenter.router = router
        presenter.logger = logger
        presenter.fileCacheStorage = fileCacheStorage
        presenter.requestService = requestService
    }
}
