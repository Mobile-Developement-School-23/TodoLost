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
    /// - Используется только 1 раз при  запуске приложения. После выполнения запрса закрывает сплешскрин.
    func getTodoListFromServer()
    /// Метод для синхронизации данных с сервером
    /// - Используется в случае других неудачных запросов. Считаем что все данные не сходятся
    /// и нужна синхронизация
    func syncTodoListWithServer(_ list: APIListResponse)
    func updateTodoItemOnServer(_ item: APIElementResponse)
    func deleteTodoItemFromServer(_ id: String)
}

final class TaskListPresenter {
    // MARK: - Architecture Properties
    
    weak var view: TaskListView?
    var router: TaskListRoutingLogic?
    
    // MARK: - Dependency properties
    
    var logger: LumberjackLogger?
    var fileCacheStorage: IFileCache?
    var networkManager: INetworkManager?
    
    // MARK: - Public properties
    
    /// Собирается в конфигураторе и используется для делегирования нажатия на кнопку
    var taskListHeader: TaskListHeaderTableView?
    
    // MARK: - Private properties
    
    private var viewModels: [TaskViewModel] = []
    /// Свойство для хранения состояния, отображать скрытые задачи или нет
    private var isShowComplete = false
    
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
            case .basic:
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
    
    /// Метод для подготовки модели к синхронизации с сервером
    /// - Returns: <#description#>
    private func fetchModelsFromCacheForServer() -> APIListResponse {
        var items: [TodoItem] = []
        
        fileCacheStorage?.items.forEach({ (_, value) in
            items.append(value)
        })
        
        return APIListResponse.convert(items)
    }
}

// MARK: - Presentation Logic

extension TaskListPresenter: TaskListPresentationLogic {
    // MARK: Network requests
    
    func getTodoListFromServer() {
        networkManager?.getTodoList(completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let serverModels):
                let todoItems = APIListResponse.convert(serverModels)
                todoItems.forEach { item in
                    self.fileCacheStorage?.addToCache(item)
                }
                
                DispatchQueue.main.async {
                    self.saveDataToStorage()
                    self.getModels()
                    self.view?.dismissSplashScreen()
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
                DispatchQueue.main.async {
                    self.getModels()
                    self.view?.dismissSplashScreen()
                }
            }
        })
    }
    
    func syncTodoListWithServer(_ list: APIListResponse) {
        networkManager?.syncTodoList(list: list, completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let serverModels):
                let todoItems = APIListResponse.convert(serverModels)
                todoItems.forEach { item in
                    self.fileCacheStorage?.addToCache(item)
                }
                self.saveDataToStorage()
                
                DispatchQueue.main.async {
                    self.getModels()
                    SystemLogger.info("Синхронизация прошла успешно")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
    }
    
    func updateTodoItemOnServer(_ item: APIElementResponse) {
        networkManager?.updateTodoItem(item: item, completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Обновление подтверждено")
                } else {
                    let apiList = self.fetchModelsFromCacheForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
    }
    
    func deleteTodoItemFromServer(_ id: String) {
        networkManager?.deleteTodoItem(id: id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Удаление подтверждено")
                } else {
                    let apiList = self.fetchModelsFromCacheForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
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
        
        let serverModel = APIElementResponse.convert(todoItem)
        updateTodoItemOnServer(serverModel)
        
        // обновляем данные после сохранения
        getModels()
    }
    
    func delete(_ task: TaskViewModel) {
        fileCacheStorage?.deleteFromCache(task.id)
        saveDataToStorage()
        deleteTodoItemFromServer(task.id)
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
            // TODO: () Перенести логику по сохранению в менеджер работы с данными
            // чтобы вся работа с фаловой системой не была в логике презентера
            // сейчас из-за этого идёт дублирование кода в модуле списка и редактирования
            do {
                try self?.fileCacheStorage?.saveToStorage(jsonFileName: "TodoList")
            } catch {
                // TODO: () Вывести алерт
            }
            
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
    }
}
