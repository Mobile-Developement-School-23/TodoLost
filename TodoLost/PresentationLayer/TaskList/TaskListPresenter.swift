//
//  TaskListPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit
import DTLogger

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskListPresentationLogic: AnyObject {
    init(view: TaskListView)
    
    func getModels()
    /// Метод для установки индекса на вью контроллере
    /// - Используется для расчета старта анимации открытия экрана и размеров фрейма
    /// - Parameter indexPath: <#indexPath description#>
    func setSelectedCell(indexPath: IndexPath)
    /// Открывает новый контроллер с текущей заметкой
    /// - Parameter id: если ID nil, откроется экран для создания новой заметки
    func openDetailTaskVC(id: String?)
    func updateHeaderView(_ doneTaskCount: Int, buttonTitle: String)
    
    func toggleVisibleTask()
    
    func delete(_ task: TaskViewModel)
    func setDoneStatus(_ task: TaskViewModel)
    
    /// Метод для получения todo списка с сервера
    func getTodoList()
    /// Метод для синхронизации данных с сервером
    func syncTodoList(list: APIListResponse)
    /// Метод для отправки единичного элемента на сервер
    func sendTodoItem(item: APIElementResponse)
    /// Метод для получения задачи с сервера по ID
    func getTodoItem(id: String)
    /// Метод для обновления todo задачи на сервере
    func updateTodoItem(item: APIElementResponse)
    /// Метод для удаления элемента с сервера по ID
    func deleteTodoItem(id: String)
}

final class TaskListPresenter {
    
    // MARK: - Public Properties
    
    weak var view: TaskListView?
    var router: TaskListRoutingLogic?
    
    var logger: LumberjackLogger?
    var fileCacheStorage: IFileCache?
    var requestService: IRequestSender?
    /// СОбирается в конфигураторе и используется для делегирования нажатия на кнопку
    var taskListHeader: TaskListHeaderTableView?
    
    // MARK: - Private properties
    
    private var viewModels: [TaskViewModel] = []
    /// Свойство для хранения состояния, отображать скрытые задачи или нет
    private var isShowComplete = false
    
    /// Используется для временного хранения текущей ревизии
    /// - Обновляется при каждом запросе к серверу
    private var revision = "0"
    
    // MARK: - Initializer
    
    required init(view: TaskListView) {
        self.view = view
    }
    
    // MARK: - Private methods
    
    private func loadDataFromStorage() {
        do {
            try fileCacheStorage?.loadFromStorage(jsonFileName: "TodoList")
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
    }
    
    private func saveDataToStorage() {
        do {
            try fileCacheStorage?.saveToStorage(jsonFileName: "TodoList")
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
    }
    
    private func fetchModelsFromCache() -> [TaskViewModel] {
        if let items = fileCacheStorage?.items {
            if items.isEmpty {
                loadDataFromStorage()
            }
        }
        
        var viewModels: [TaskViewModel] = []
        
        fileCacheStorage?.items.forEach({ (_, value) in
            
            // TODO: () ВОзможно стоит хранить какой то статус по умолчанию в классе
            // чтобы была возможность вернуть его, когда пользователь отменяет
            // задачу как выполенную, а не устанавливать его по умолчанию
            var statusTask: StatusTask = .statusDefault
            
            switch value.importance {
            case .low:
                statusTask = .statusLow
            case .normal:
                statusTask = .statusDefault
            case .important:
                statusTask = .statusHigh
            }
            
            if value.isDone {
                statusTask = .statusDone
            }
            
            let viewModel = TaskViewModel(
                id: value.id,
                dateCreated: value.dateCreated,
                status: statusTask,
                title: value.text,
                subtitle: value.deadline?.toString(format: "dd MMMM"),
                importance: value.importance,
                deadline: value.deadline,
                isDone: value.isDone,
                dateEdited: value.dateEdited,
                hexColor: value.hexColor
            )
            
            viewModels.append(viewModel)
        })
        
        return viewModels
    }
}

// MARK: - Presentation Logic

extension TaskListPresenter: TaskListPresentationLogic {
    // MARK: Server requests
    
    // ???: Почему то дублируется логгер, как будто возникает утечка памяти.
    // Мой класс логгера 1 единственный, а вот под капотом что то идёт не так.
    func getTodoList() {
        SystemLogger.info("Отправлен запрос на получение списка дел")
//        logger?.logInfoMessage("Отправлен запрос на получение списка дел")
        
        let requestConfig = RequestFactory.TodoListRequest.getListConfig()
        requestService?.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Не удалось получить модель")
//                    self?.logger?.logWarningMessage("Не удалось получить модель")
                    return
                }
                
                self?.revision = String(model.revision)
                
                if let revision = self?.revision {
                    SystemLogger.info("Данные получены, новая ревизия: \(revision)")
//                    self?.logger?.logInfoMessage("Данные получены, новая ревизия: \(revision)")
                }
            case .failure(let error):
                self?.logger?.logErrorMessage(error.describing)
            }
        }
    }
    
    func syncTodoList(list: APIListResponse) {
        SystemLogger.info("Отправлен запрос на синхронизацию данных")
//        logger?.logInfoMessage("Отправлен запрос на синхронизацию данных")
        
        let requestConfig = RequestFactory.TodoListRequest.patchListConfig(list: list, revision: revision)
        requestService?.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не синхронизированы")
//                    self?.logger?.logWarningMessage("Данные не сохранены")
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные синхронизированы, новая ревизия: \(revision)")
//                    self?.logger?.logInfoMessage("Данные сохранены, новая ревизия: \(revision)")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        }
    }
    
    func sendTodoItem(item: APIElementResponse) {
        SystemLogger.info("Отправлен запрос на добавление элемента: \(item.element.id)")
//        logger?.logInfoMessage("Отправлен запрос на добавление элемента: \(item.element.id)")
        
        let requestConfig = RequestFactory.TodoListRequest.postItemConfig(dataModel: item, revision: revision)
        requestService?.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не сохранены")
//                    self?.logger?.logWarningMessage("Данные не сохранены")
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные сохранены, новая ревизия: \(revision)")
//                    self?.logger?.logInfoMessage("Данные сохранены, новая ревизия: \(revision)")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        }
    }
    
    func getTodoItem(id: String) {
        SystemLogger.info("Отправлен запрос на получение элемента: \(id)")
//        logger?.logInfoMessage("Отправлен запрос на получение элемента: \(id)")
        
        let requestConfig = RequestFactory.TodoListRequest.getItemConfig(id: id, revision: revision)
        requestService?.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не получены")
//                    self?.logger?.logWarningMessage("Данные не получены")
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные получены. Ревизия: \(revision)")
//                    self?.logger?.logInfoMessage("Данные получены. Ревизия: \(revision)")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        }
    }
    
    func updateTodoItem(item: APIElementResponse) {
        SystemLogger.info("Отправлен запрос на обновление элемента: \(item.element.id)")
//        logger?.logInfoMessage("Отправлен запрос на обновление элемента: \(item.element.id)")
        
        let requestConfig = RequestFactory.TodoListRequest.putItemConfig(
            dataModel: item,
            id: item.element.id,
            revision: revision
        )
        
        requestService?.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не обновлены")
//                    self?.logger?.logWarningMessage("Данные не обновлены")
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные обновлены, новая ревизия: \(revision)")
//                    self?.logger?.logInfoMessage("Данные обновлены, новая ревизия: \(revision)")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        }
    }
    
    func deleteTodoItem(id: String) {
        SystemLogger.info("Отправлен запрос на удаление элемента: \(id)")
//        logger?.logInfoMessage("Отправлен запрос на удаление элемента: \(id)")
        
        let requestConfig = RequestFactory.TodoListRequest.deleteItemConfig(id: id, revision: revision)
        requestService?.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let(model, _, _)):
                guard let model else {
                    SystemLogger.warning("Данные не удалены")
//                    self?.logger?.logWarningMessage("Данные не удалены")
                    return
                }
                
                self?.revision = String(model.revision)
                if let revision = self?.revision {
                    SystemLogger.info("Данные удалены, новая ревизия: \(revision)")
//                    self?.logger?.logInfoMessage("Данные удалены, новая ревизия: \(revision)")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        }
    }
    
    // MARK: Others
    
    func setSelectedCell(indexPath: IndexPath) {
        view?.setSelectedCell(indexPath: indexPath)
    }
    
    func setDoneStatus(_ task: TaskViewModel) {
        var isDone = task.isDone
        isDone.toggle()
        
        let todoItem = TodoItem(
            id: task.id,
            text: task.title,
            importance: task.importance,
            deadline: task.deadline,
            isDone: isDone,
            dateCreated: task.dateCreated,
            dateEdited: task.dateEdited,
            hexColor: task.hexColor
        )
        
        fileCacheStorage?.addToCache(todoItem)
        saveDataToStorage()
        // обновляем данные после сохранения
        getModels()
    }
    
    func delete(_ task: TaskViewModel) {
        fileCacheStorage?.deleteFromCache(task.id)
        saveDataToStorage()
        // обновляем данные после удаления
        getModels()
    }
    
    func toggleVisibleTask() {
        isShowComplete.toggle()
        view?.display(models: viewModels, isShowComplete: isShowComplete)
    }
    
    func updateHeaderView(_ doneTaskCount: Int, buttonTitle: String) {
        view?.display(doneTaskCount: "Выполнено — \(doneTaskCount)", buttonTitle: buttonTitle)
    }
    
    func openDetailTaskVC(id: String?) {
        router?.routeTo(target: .taskDetail(id)) { [weak self] in
            // TODO: () Перенести логику по сохранению на главный экран
            // а экран редактирования оставить так, чтобы он ничего не делал с
            // памятью и только брал данные из кеша. То есть по колбеку вызывать
            // не обновление массива, а производить сохранение, удаление и т.д.
            self?.getModels()
        }
    }
    
    func getModels() {
        viewModels = fetchModelsFromCache().sorted { $0.dateCreated > $1.dateCreated }
        
        if viewModels.isEmpty {
            view?.presentPlaceholder()
        } else {
            view?.hidePlaceholder()
        }
        
        view?.display(models: viewModels, isShowComplete: isShowComplete)
        view?.dismissSplashScreen()
    }
}
