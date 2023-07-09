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
    
    func createDB()
}

final class TaskListPresenter {
    // MARK: - Architecture Properties
    
    weak var view: TaskListView?
    var router: TaskListRoutingLogic?
    
    // MARK: - Dependency properties
    
    var logger: LumberjackLogger?
    var fileCacheStorage: IFileCache?
    var sqliteStorage: ISQLiteStorage?
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
    
    private func fetchModelsFromDB() -> [TaskViewModel] {
        var viewModels: [TaskViewModel] = []
        var dbTodoItems: [TodoItem] = []
        
        do {
            if let items = try sqliteStorage?.load() {
                dbTodoItems = items
            }
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        
        dbTodoItems.forEach({ value in
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
    private func fetchModelsFromDBForServer() -> APIListResponse {
        var items: [TodoItem] = []
        
        do {
            if let dbItems = try sqliteStorage?.load() {
                items = dbItems
            }
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        
        return APIListResponse.convert(items)
    }
}

// MARK: - Presentation Logic

extension TaskListPresenter: TaskListPresentationLogic {
    // MARK: SQLite requests
    
    func createDB() {
        do {
            try sqliteStorage?.fetchOrCreateDB()
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
    }
    
    // MARK: Network requests
    
    func getTodoListFromServer() {
        view?.startActivityAnimating()
        
        networkManager?.getTodoList(completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let serverModels):
                let todoItems = APIListResponse.convert(serverModels)
                todoItems.forEach { item in
                    do {
                        try self.sqliteStorage?.insertOrReplace(item: item)
                    } catch {
                        SystemLogger.error(error.localizedDescription)
                    }
                }
                
                DispatchQueue.main.async {
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
        
        networkManager?.hideActivityIndicator { [weak self] in
            self?.view?.stopActivityAnimating()
        }
    }
    
    func syncTodoListWithServer(_ list: APIListResponse) {
        view?.startActivityAnimating()
        
        networkManager?.syncTodoList(list: list, completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let serverModels):
                let todoItems = APIListResponse.convert(serverModels)
                todoItems.forEach { item in
                    do {
                        try self.sqliteStorage?.insertOrReplace(item: item)
                    } catch {
                        SystemLogger.error(error.localizedDescription)
                    }
                }
                
                DispatchQueue.main.async {
                    self.getModels()
                    SystemLogger.info("Синхронизация прошла успешно")
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
        
        networkManager?.hideActivityIndicator { [weak self] in
            self?.view?.stopActivityAnimating()
        }
    }
    
    func updateTodoItemOnServer(_ item: APIElementResponse) {
        view?.startActivityAnimating()
        
        networkManager?.updateTodoItem(item: item, completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Обновление подтверждено")
                } else {
                    let apiList = self.fetchModelsFromDBForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
        
        networkManager?.hideActivityIndicator { [weak self] in
            self?.view?.stopActivityAnimating()
        }
    }
    
    func deleteTodoItemFromServer(_ id: String) {
        view?.startActivityAnimating()
        
        networkManager?.deleteTodoItem(id: id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Удаление подтверждено")
                } else {
                    let apiList = self.fetchModelsFromDBForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
        
        networkManager?.hideActivityIndicator { [weak self] in
            self?.view?.stopActivityAnimating()
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
        
        do {
            try self.sqliteStorage?.insertOrReplace(item: todoItem)
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        
        let serverModel = APIElementResponse.convert(todoItem)
        updateTodoItemOnServer(serverModel)
        
        // обновляем данные после сохранения
        getModels()
    }
    
    func delete(_ task: TaskViewModel) {
        do {
            try self.sqliteStorage?.delete(id: task.id)
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
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
        view?.startActivityAnimating()
        
        guard let sqliteStorage else {
            assertionFailure("К такому жизнь нас не готовила. SQL база не инициализирована")
            return
        }
        
        router?.routeTo(
            target: .taskDetail(id),
            sqliteStorage: sqliteStorage,
            completion: { [weak self] in
                self?.getModels()
                
                self?.networkManager?.hideActivityIndicator { [weak self] in
                    self?.view?.stopActivityAnimating()
                }
            },
            cancelCompletion: { [weak self] in
                self?.view?.stopActivityAnimating()
            }
        )
    }
    
    func getModels() {
        viewModels = fetchModelsFromDB().sorted { $0.dateCreated > $1.dateCreated }
        
        if viewModels.isEmpty {
            view?.presentPlaceholder()
        } else {
            view?.hidePlaceholder()
        }
        
        view?.display(models: viewModels, isShowComplete: isShowComplete)
    }
}
