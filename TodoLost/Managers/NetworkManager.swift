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
    ///   - completion: Возвращает с сервера данные, которые удалось синхронизировать
    func syncTodoList(
        list: APIListResponse,
        completion: @escaping (Result<APIListResponse, NetworkError>) -> Void
    )
    
    /// Метод для создания новой todo задачи на сервере
    /// - Запрос работает на глобал очереди, так-как при создании конфигурации
    /// происходит парсинг данных.
    /// - Parameter item: <#item description#>
    func sendTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
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
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    )
    
    /// Метод для удаление todo задачи с сервера
    /// - Parameters:
    ///   - id: идентификатор, по которому задача будет удалена
    ///   - completion: <#completion description#>
    func deleteTodoItem(
        id: String,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    )
    
    /// Скрывает активити индикатор
    /// - Parameter completion: выполняет блок кода, после того как все задачи в группе
    /// были завершены и не осталось больше ни одного сетевого запроса.
    func hideActivityIndicator(completion: @escaping () -> Void)
}

final class NetworkManager {
    // MARK: - Dependencies
    
    private let requestService: IRequestSender
    private let logger: LumberjackLogger
    
    // MARK: - Private properties
    
    /// Используется для хранения текущей ревизии
    /// - Обновляется при каждом запросе к серверу
    private var revision = "0"
    private var isDirty = false
    
    // параметры для retry запроса
    private var shouldRetry = true
    private let minDelay: TimeInterval = 2.0
    private let maxDelay: TimeInterval = 120.0
    private let factor: Double = 1.5
    private let jitter: Double = 0.05
    
    private var queue = DispatchQueue(
        label: "ru.TodoLost.networkRequest",
        qos: .userInteractive
    )
    /// Используется для блокировки потока, пока не будет получен результат запроса к серверу
    private var semaphore = DispatchSemaphore(value: 0)
    private var group = DispatchGroup()
    
    // MARK: - Initializer
    
    init(
        requestService: IRequestSender,
        logger: LumberjackLogger
    ) {
        self.requestService = requestService
        self.logger = logger
    }
    
    func exponentialRetry(
        requestCount: Int,
        minDelay: TimeInterval,
        maxDelay: TimeInterval,
        factor: Double,
        jitter: Double,
        action: @escaping () -> Void
    ) {
        queue.async(group: group) { [weak self] in
            guard let self else { return }
            
            guard self.shouldRetry else {
                SystemLogger.warning("Количество попыток отправить запрос превышено. isDirty: \(self.isDirty)")
                return
            }
            
            // Запускает выполнение запроса к серверу
            action()
            
            SystemLogger.info("Ожидание результата запроса")
            self.semaphore.wait()
            
            if self.shouldRetryRequest() {
                let baseDelay = minDelay * pow(factor, Double(requestCount - 1))
                
                let randomJitter = (Double.random(in: -jitter...jitter)) * baseDelay
                let delay = min(baseDelay + randomJitter, maxDelay)
                
                if delay >= maxDelay {
                    self.shouldRetry = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    SystemLogger.warning("Повторный запрос. Задержка: \(delay)")
                    self?.exponentialRetry(
                        requestCount: requestCount + 1,
                        minDelay: minDelay,
                        maxDelay: maxDelay,
                        factor: factor,
                        jitter: jitter,
                        action: action
                    )
                }
            } else {
                self.isDirty = false
                SystemLogger.info("Запрос выполнен успешно")
            }
        }
        
    }
    
    private func shouldRetryRequest() -> Bool {
        return isDirty
    }
    
}

// MARK: - INetworkManager

extension NetworkManager: INetworkManager {
    func hideActivityIndicator(completion: @escaping () -> Void) {
        group.notify(queue: .main) {
            SystemLogger.warning("Все задачи завершены")
            completion()
        }
    }
    
    func getTodoList(completion: @escaping (Result<APIListResponse, NetworkError>) -> Void) {
        let requestConfig = RequestFactory.TodoListRequest.getListConfig()
        
        SystemLogger.info("Отправлен запрос на получение списка дел")
        logger.logInfoMessage("Отправлен запрос на получение списка дел")
        
        exponentialRetry(
            requestCount: 1,
            minDelay: minDelay,
            maxDelay: maxDelay,
            factor: factor,
            jitter: jitter
        ) {
            self.requestService.send(config: requestConfig) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let(model, _, _)):
                    guard let model else {
                        SystemLogger.warning("Не удалось получить модель")
                        self.logger.logWarningMessage("Не удалось получить модель")
                        self.isDirty = true
                        completion(.failure(.unownedError))
                        semaphore.signal()
                        return
                    }
                    
                    self.revision = String(model.revision)
                    SystemLogger.info("Данные получены, новая ревизия: \(self.revision)")
                    self.logger.logInfoMessage("Данные получены, новая ревизия: \(self.revision)")
                    self.isDirty = false
                    completion(.success(model))
                    semaphore.signal()
                case .failure(let error):
                    SystemLogger.error(error.describing)
                    self.logger.logErrorMessage(error.describing)
                    self.isDirty = true
                    completion(.failure(error))
                    semaphore.signal()
                }
            }
        }
    }
    
    func syncTodoList(
        list: APIListResponse,
        completion: @escaping (Result<APIListResponse, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на синхронизацию данных")
        logger.logInfoMessage("Отправлен запрос на синхронизацию данных")
        
        queue.async(group: group) { [weak self] in
            guard let self else { return }
            
            let requestConfig = RequestFactory.TodoListRequest.patchListConfig(
                list: list,
                revision: self.revision
            )
            
            self.exponentialRetry(
                requestCount: 1,
                minDelay: self.minDelay,
                maxDelay: self.maxDelay,
                factor: self.factor,
                jitter: self.jitter
            ) {
                self.requestService.send(config: requestConfig) { [weak self] result in
                    switch result {
                    case .success(let(model, _, _)):
                        guard let model else {
                            SystemLogger.warning("Данные не синхронизированы")
                            self?.logger.logWarningMessage("Данные не сохранены")
                            completion(.failure(.unownedError))
                            self?.semaphore.signal()
                            return
                        }
                        
                        self?.revision = String(model.revision)
                        if let revision = self?.revision {
                            SystemLogger.info("Данные синхронизированы, новая ревизия: \(revision)")
                            self?.logger.logInfoMessage("Данные сохранены, новая ревизия: \(revision)")
                        }
                        
                        self?.isDirty = false
                        completion(.success((model)))
                        self?.semaphore.signal()
                    case .failure(let error):
                        SystemLogger.error(error.describing)
                        completion(.failure(error))
                        self?.semaphore.signal()
                    }
                }
            }
        }
    }
    
    func sendTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на добавление элемента: \(item.element.id)")
        logger.logInfoMessage("Отправлен запрос на добавление элемента: \(item.element.id)")
        
        queue.async(group: group) { [weak self] in
            guard let self else { return }
            
            let requestConfig = RequestFactory.TodoListRequest.postItemConfig(
                dataModel: item,
                revision: self.revision
            )
            
            self.exponentialRetry(
                requestCount: 1,
                minDelay: self.minDelay,
                maxDelay: self.maxDelay,
                factor: self.factor,
                jitter: self.jitter
            ) {
                SystemLogger.info("Отправлен запрос на добавление элемента: \(item.element.id)")
                self.logger.logInfoMessage("Отправлен запрос на добавление элемента: \(item.element.id)")
                
                SystemLogger.warning(self.revision)
                
                self.requestService.send(config: requestConfig) { [weak self] result in
                    guard let self else { return }
                    
                    switch result {
                    case .success(let(model, _, _)):
                        guard let model else {
                            SystemLogger.warning("Данные не сохранены")
                            self.logger.logWarningMessage("Данные не сохранены")
                            self.isDirty = true
                            completion(.failure(.unownedError))
                            semaphore.signal()
                            return
                        }
                        
                        self.revision = String(model.revision)
                        SystemLogger.info("Данные сохранены, новая ревизия: \(self.revision)")
                        self.logger.logInfoMessage("Данные сохранены, новая ревизия: \(self.revision)")
                        completion(.success((self.isDirty)))
                        semaphore.signal()
                    case .failure(let error):
                        self.isDirty = true
                        SystemLogger.error(error.describing)
                        completion(.failure(error))
                        semaphore.signal()
                    }
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
        
        exponentialRetry(
            requestCount: 1,
            minDelay: minDelay,
            maxDelay: maxDelay,
            factor: factor,
            jitter: jitter
        ) { [weak self] in
            self?.requestService.send(config: requestConfig) { [weak self] result in
                switch result {
                case .success(let(model, _, _)):
                    guard let model else {
                        SystemLogger.warning("Данные не получены")
                        self?.logger.logWarningMessage("Данные не получены")
                        completion(.failure(.unownedError))
                        self?.semaphore.signal()
                        return
                    }
                    
                    self?.revision = String(model.revision)
                    if let revision = self?.revision {
                        SystemLogger.info("Данные получены. Ревизия: \(revision)")
                        self?.logger.logInfoMessage("Данные получены. Ревизия: \(revision)")
                    }
                    
                    completion(.success((model)))
                    self?.semaphore.signal()
                case .failure(let error):
                    SystemLogger.error(error.describing)
                    completion(.failure(error))
                    self?.semaphore.signal()
                }
            }
        }

    }
    
    func updateTodoItem(
        item: APIElementResponse,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        
        queue.async(group: group) { [weak self] in
            guard let self else { return }
            
            SystemLogger.info("Отправлен запрос на обновление элемента: \(item.element.id)")
            self.logger.logInfoMessage("Отправлен запрос на обновление элемента: \(item.element.id)")
            
            let requestConfig = RequestFactory.TodoListRequest.putItemConfig(
                dataModel: item,
                id: item.element.id,
                revision: self.revision
            )
            
            exponentialRetry(
                requestCount: 1,
                minDelay: minDelay,
                maxDelay: maxDelay,
                factor: factor,
                jitter: jitter
            ) {
                self.requestService.send(config: requestConfig) { [weak self] result in
                    guard let self else { return }
                    
                    switch result {
                    case .success(let(model, _, _)):
                        guard let model else {
                            SystemLogger.warning("Данные не обновлены")
                            self.logger.logWarningMessage("Данные не обновлены")
                            self.isDirty = true
                            completion(.failure(.unownedError))
                            self.semaphore.signal()
                            return
                        }
                        
                        self.revision = String(model.revision)
                        SystemLogger.info("Данные обновлены, новая ревизия: \(self.revision)")
                        self.logger.logInfoMessage("Данные обновлены, новая ревизия: \(self.revision)")
                        
                        completion(.success((self.isDirty)))
                        self.semaphore.signal()
                    case .failure(let error):
                        SystemLogger.error(error.describing)
                        self.isDirty = true
                        completion(.failure(error))
                        self.semaphore.signal()
                    }
                }
            }
        }
    }
    
    func deleteTodoItem(
        id: String,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        SystemLogger.info("Отправлен запрос на удаление элемента: \(id)")
        logger.logInfoMessage("Отправлен запрос на удаление элемента: \(id)")
        
        let requestConfig = RequestFactory.TodoListRequest.deleteItemConfig(id: id, revision: revision)
        
        exponentialRetry(
            requestCount: 1,
            minDelay: minDelay,
            maxDelay: maxDelay,
            factor: factor,
            jitter: jitter
        ) { [weak self] in
            self?.requestService.send(config: requestConfig) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let(model, _, _)):
                    guard let model else {
                        SystemLogger.warning("Данные не удалены")
                        self.logger.logWarningMessage("Данные не удалены")
                        self.isDirty = true
                        completion(.failure(.unownedError))
                        self.semaphore.signal()
                        return
                    }
                    
                    self.revision = String(model.revision)
                    SystemLogger.info("Данные удалены, новая ревизия: \(self.revision)")
                    self.logger.logErrorMessage("Данные удалены, новая ревизия: \(self.revision)")
                    
                    completion(.success((self.isDirty)))
                    self.semaphore.signal()
                case .failure(let error):
                    SystemLogger.error(error.describing)
                    self.isDirty = true
                    completion(.failure(error))
                    self.semaphore.signal()
                }
            }
        }
    }
}
