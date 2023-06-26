//
//  PresentationAssembly.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

final class PresentationAssembly {
    private var service = ServiceAssembly()
    
    lazy var taskList: TaskListConfigurator = {
        return TaskListConfigurator()
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
