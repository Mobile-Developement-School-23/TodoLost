//
//  ServiceAssembly.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 21.06.2023.
//

import Foundation

final class ServiceAssembly {
    lazy var logger: LumberjackLogger = {
        return LumberjackLogger.shared
    }()
    
    lazy var fileCacheStorage: IFileCache = {
        var fileCache = FileCache.shared
        fileCache.logger = logger
        return fileCache
    }()
    
    lazy var sqliteStorage: ISQLiteStorage = {
        return SQLiteStorage()
    }()
    
    lazy var coreDataStorage: ICoreDataStorage = {
        return CoreDataStorage.shared
    }()
    
    lazy var requestService: IRequestSender = {
        var requestService = RequestSender()
        return requestService
    }()
    
    lazy var notificationKeyboardObserver: INotificationKeyboardObserver = {
       return NotificationKeyboardObserver()
    }()
}
