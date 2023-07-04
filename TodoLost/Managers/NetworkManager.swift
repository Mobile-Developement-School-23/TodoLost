//
//  NetworkManager.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 04.07.2023.
//

import Foundation
import DTLogger
import CocoaLumberjackSwift

protocol INetworkManager {
    func getTodoList(completion: @escaping (Result<APIListResponse, NetworkError>) -> Void)
    
    /// Метод для синхронизации данных с сервером
    /// - Запрос работает на глобал очереди, так-как при создании конфигурации
    /// происходит парсинг данных.
    /// - Parameters:
    ///   - list: принимает модель API сервера которая будет синхронизирована
    ///   - completion: <#completion description#>
    func syncTodoList(
        list: APIListResponse,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    
    /// Метод для создания новой todo задачи на сервере
    /// - Запрос работает на глобал очереди, так-как при создании конфигурации
    /// происходит парсинг данных.
    /// - Parameter item: <#item description#>
    func sendTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    
    /// Метод для загрузки задачи с сервера по её ID
    /// - Parameters:
    ///   - id: идентификатор задачи, по которой будет производится поиск на сервере
    ///   - completion: <#completion description#>
    func getTodoItem(
        id: String,
        completion: @escaping (Result<APIElementResponse, NetworkError>) -> Void
    )
    
    /// Метод для обновление todo задачи на сервере
    /// - Запрос работает на глобал очереди, так-как при создании конфигурации
    /// происходит парсинг данных.
    /// - Parameters:
    ///   - item: <#item description#>
    ///   - completion: <#completion description#>
    func updateTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    
    /// Метод для удаление todo задачи с сервера
    /// - Parameters:
    ///   - id: идентификатор, по которому задача будет удалена
    ///   - completion: <#completion description#>
    func deleteTodoItem(
        id: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
}

final class NetworkManager {
    // MARK: - Dependencies
    
    private let requestService: IRequestSender
    private let logger: LumberjackLogger
    
    // MARK: - Private properties
    
    /// Используется для хранения текущей ревизии
    /// - Обновляется при каждом запросе к серверу
    private var revision = "0"
    
    private var queue = DispatchQueue(
        label: "ru.TodoLost.networkRequest",
        qos: .userInteractive
    )
    
    // MARK: - Initializer
    
    init(
        requestService: IRequestSender,
        logger: LumberjackLogger
    ) {
        self.requestService = requestService
        self.logger = logger
    }
}

// MARK: - INetworkManager

extension NetworkManager: INetworkManager {
    func getTodoList(completion: @escaping (Result<APIListResponse, NetworkError>) -> Void) {
        SystemLogger.info("Отправлен запрос на получение списка дел")
        logger.logInfoMessage("Отправлен запрос на получение списка дел")
        
        let requestConfig = RequestFactory.TodoListRequest.getListConfig()
        requestService.send(config: requestConfig) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Не удалось получить модель")
                    self.logger.logWarningMessage("Не удалось получить модель")
                    completion(.failure(.unownedError))
                    return
                }
                
                self.revision = String(model.revision)
                SystemLogger.info("Данные получены, новая ревизия: \(self.revision)")
                self.logger.logInfoMessage("Данные получены, новая ревизия: \(self.revision)")
                completion(.success(model))
            case .failure(let error):
                SystemLogger.error(error.describing)
                self.logger.logErrorMessage(error.describing)
                completion(.failure(error))
            }
        }
    }
    
    func syncTodoList(
        list: APIListResponse,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на синхронизацию данных")
        logger.logInfoMessage("Отправлен запрос на синхронизацию данных")
        
        queue.async { [weak self] in
            guard let self else { return }
            
            let requestConfig = RequestFactory.TodoListRequest.patchListConfig(
                list: list,
                revision: self.revision
            )
            
            self.requestService.send(config: requestConfig) { [weak self] result in
                switch result {
                case .success(let(model, _, _)):
                    guard let model else {
                        SystemLogger.warning("Данные не синхронизированы")
                        self?.logger.logWarningMessage("Данные не сохранены")
                        completion(.failure(.unownedError))
                        return
                    }
                    
                    self?.revision = String(model.revision)
                    if let revision = self?.revision {
                        SystemLogger.info("Данные синхронизированы, новая ревизия: \(revision)")
                        self?.logger.logInfoMessage("Данные сохранены, новая ревизия: \(revision)")
                    }
                    
                    completion(.success(()))
                case .failure(let error):
                    SystemLogger.error(error.describing)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func sendTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на добавление элемента: \(item.element.id)")
        logger.logInfoMessage("Отправлен запрос на добавление элемента: \(item.element.id)")
        
        queue.async { [weak self] in
            guard let self else { return }
            
            let requestConfig = RequestFactory.TodoListRequest.postItemConfig(
                dataModel: item,
                revision: self.revision
            )
            
            self.requestService.send(config: requestConfig) { [weak self] result in
                switch result {
                case .success(let(model, _, _)):
                    guard let model else {
                        SystemLogger.warning("Данные не сохранены")
                        self?.logger.logWarningMessage("Данные не сохранены")
                        completion(.failure(.unownedError))
                        return
                    }
                    
                    self?.revision = String(model.revision)
                    if let revision = self?.revision {
                        SystemLogger.info("Данные сохранены, новая ревизия: \(revision)")
                        self?.logger.logInfoMessage("Данные сохранены, новая ревизия: \(revision)")
                    }
                    completion(.success(()))
                case .failure(let error):
                    SystemLogger.error(error.describing)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getTodoItem(
        id: String,
        completion: @escaping (Result<APIElementResponse, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на получение элемента: \(id)")
        logger.logInfoMessage("Отправлен запрос на получение элемента: \(id)")
        
        let requestConfig = RequestFactory.TodoListRequest.getItemConfig(
            id: id,
            revision: revision
        )
        
        requestService.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не получены")
                    self?.logger.logWarningMessage("Данные не получены")
                    completion(.failure(.unownedError))
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные получены. Ревизия: \(revision)")
                    self?.logger.logInfoMessage("Данные получены. Ревизия: \(revision)")
                }
                
                completion(.success((model)))
            case .failure(let error):
                SystemLogger.error(error.describing)
                completion(.failure(error))
            }
        }
    }
    
    func updateTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на обновление элемента: \(item.element.id)")
        logger.logInfoMessage("Отправлен запрос на обновление элемента: \(item.element.id)")
        
        queue.async { [weak self] in
            guard let self else { return }
            
            let requestConfig = RequestFactory.TodoListRequest.putItemConfig(
                dataModel: item,
                id: item.element.id,
                revision: self.revision
            )
            
            requestService.send(config: requestConfig) { [weak self] result in
                switch result {
                case .success(let(model, _, _)):
                    guard let model else {
                        SystemLogger.warning("Данные не обновлены")
                        self?.logger.logWarningMessage("Данные не обновлены")
                        completion(.failure(.unownedError))
                        return
                    }
                    
                    self?.revision = String(model.revision)
                    if let revision = self?.revision {
                        SystemLogger.info("Данные обновлены, новая ревизия: \(revision)")
                        self?.logger.logInfoMessage("Данные обновлены, новая ревизия: \(revision)")
                    }
                    
                    completion(.success(()))
                case .failure(let error):
                    SystemLogger.error(error.describing)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteTodoItem(
        id: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на удаление элемента: \(id)")
        logger.logInfoMessage("Отправлен запрос на удаление элемента: \(id)")
        
        let requestConfig = RequestFactory.TodoListRequest.deleteItemConfig(id: id, revision: revision)
        requestService.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не удалены")
                    self?.logger.logWarningMessage("Данные не удалены")
                    completion(.failure(.unownedError))
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные удалены, новая ревизия: \(revision)")
                    self?.logger.logErrorMessage("Данные удалены, новая ревизия: \(revision)")
                }
                
                completion(.success(()))
            case .failure(let error):
                SystemLogger.error(error.describing)
                completion(.failure(error))
            }
        }
    }
}
