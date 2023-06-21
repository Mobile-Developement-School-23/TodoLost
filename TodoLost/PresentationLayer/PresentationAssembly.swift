//
//  PresentationAssembly.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

final class PresentationAssembly {
    private var service = ServiceAssembly()
    
    lazy var taskDetail: TaskDetailConfigurator = {
        return TaskDetailConfigurator(fileCacheStorage: service.fileCacheStorage)
    }()
}
