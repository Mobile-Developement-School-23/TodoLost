//
//  PresentationAssembly.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

final class PresentationAssembly {
    private var service = ServiceAssembly()
    
    // TODO: () Сделать отдельный Assembly для менеджеров, когда их станет больше
    private lazy var networkManager: INetworkManager = NetworkManager(
        requestService: service.requestService,
        logger: service.logger
    )
    
    lazy var taskList: TaskListConfigurator = {
        return TaskListConfigurator(
            logger: service.logger,
            fileCacheStorage: service.fileCacheStorage,
            splashScreenPresenter: SplashScreenPresenter(),
            networkManager: networkManager
        )
    }()
    
    lazy var taskDetail: TaskDetailConfigurator = {
        return TaskDetailConfigurator(
            fileCacheStorage: service.fileCacheStorage,
            notificationKeyboardObserver: service.notificationKeyboardObserver
        )
    }()
    
    lazy var colorPicker: ColorPickerConfigurator = {
       return ColorPickerConfigurator()
    }()
}
