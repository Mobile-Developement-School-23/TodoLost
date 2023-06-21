//
//  ServiceAssembly.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 21.06.2023.
//

import Foundation

final class ServiceAssembly {
    lazy var fileCacheStorage: IFileCache = {
        return FileCache()
    }()
}

