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
    private let notificationKeyboardObserver: INotificationKeyboardObserver
    
    init(
        fileCacheStorage: IFileCache,
        notificationKeyboardObserver: INotificationKeyboardObserver
    ) {
        self.fileCacheStorage = fileCacheStorage
        self.notificationKeyboardObserver = notificationKeyboardObserver
    }
    
    func config(
        view: UIViewController,
        navigationController: UINavigationController,
        networkManager: INetworkManager,
        sqliteStorage: ISQLiteStorage,
        coreDataStorage: ICoreDataStorage,
        itemID: String?,
        completion: (() -> Void)?,
        cancelCompletion: (() -> Void)?
    ) {
        guard let view = view as? TaskDetailViewController else { return }
        let presenter = TaskDetailPresenter(view: view)
        let router = TaskDetailRouter(withNavigationController: navigationController)
        
        view.presenter = presenter
        view.observerKeyboard = notificationKeyboardObserver
        presenter.view = view
        presenter.router = router
        presenter.fileCacheStorage = fileCacheStorage
        presenter.networkManager = networkManager
        presenter.sqliteStorage = sqliteStorage
        presenter.coreDataStorage = coreDataStorage
        presenter.itemID = itemID
        presenter.completion = completion
        presenter.cancelCompletion = cancelCompletion
    }
}
