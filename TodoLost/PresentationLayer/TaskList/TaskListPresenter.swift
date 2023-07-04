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
    func sendTodoItemToServer(_ item: APIElementResponse)
    func getTodoItemFromServer(_ id: String)
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
    
    /// Метод для конвертации при отправке или обновлении задачи на сервере
    /// - Parameter task: <#task description#>
    /// - Returns: <#description#>
    /// - warning: Данная конвертация производится только при обновлении и добовлении модели на сервере.
    /// При конвертации присваивается текущая дата изменения.
    private func convertToServerModel(_ task: TodoItem) -> APIElementResponse {
        var deadlineInt: Int64?
        if let deadline = task.deadline?.timeIntervalSince1970 {
            deadlineInt = Int64(deadline)
        }
        
        let dateCreated = Int64(task.dateCreated.timeIntervalSince1970)
        
        let model = APIElementResponse(
            status: "",
            element: TodoItemServerModel(
                id: task.id,
                text: task.text,
                importance: task.importance.rawValue,
                deadline: deadlineInt,
                done: task.isDone,
                color: task.hexColor,
                createdAt: dateCreated,
                changedAt: Int64(Date.now.timeIntervalSince1970),
                lastUpdatedBy: UIDevice.current.name
            ),
            revision: 0
        )
        
        return model
    }
    
    /// Метод для конвертации  списка дел при отправке обновления на сервер
    /// - Parameter tasks: <#tasks description#>
    /// - Returns: <#description#>
    /// - Используется при синхронизации данных сервером
    private func convertModelsToServerModel(_ tasks: [TaskViewModel]) -> APIListResponse {
        var items: [TodoItemServerModel] = []
        
        tasks.forEach { task in
            var deadlineInt: Int64?
            if let deadline = task.deadline?.timeIntervalSince1970 {
                deadlineInt = Int64(deadline)
            }
            
            let dateCreated = Int64(task.dateCreated.timeIntervalSince1970)
            var dateEditedInt = dateCreated
            if let dateEdited = task.dateEdited?.timeIntervalSince1970 {
                dateEditedInt = Int64(dateEdited)
            }
            
            let item = TodoItemServerModel(
                id: task.id,
                text: task.title,
                importance: task.importance.rawValue,
                deadline: deadlineInt,
                done: task.isDone,
                color: task.hexColor,
                createdAt: dateCreated,
                changedAt: dateEditedInt,
                lastUpdatedBy: UIDevice.current.name
            )
            
            items.append(item)
        }
        
        let model = APIListResponse(
            status: "",
            list: items,
            revision: 0
        )
        
        return model
    }
    
    /// Метод для конвертации полученных данных с сервера
    /// - Parameter serverModels: <#serverModels description#>
    /// - Returns: <#description#>
    /// - Используется при получении серверной модели перед сохранением данных в память устройства
    private func convertToViewModelFrom(_ serverModels: APIListResponse) -> [TodoItem] {
        var todoItems: [TodoItem] = []
        
        serverModels.list.forEach { model in
            
            let deadlineTimestamp = Double(model.createdAt) as TimeInterval
            let dateCreated = Date(timeIntervalSince1970: deadlineTimestamp)
            
            var deadline: Date?
            if let deadlineInt = model.deadline {
                let deadlineTimestamp = Double(deadlineInt) as TimeInterval
                deadline = Date(timeIntervalSince1970: deadlineTimestamp)
            }
            
            let dateEditedTimestamp = Double(model.changedAt) as TimeInterval
            let dateEdited = Date(timeIntervalSince1970: dateEditedTimestamp)
            
            let item = TodoItem(
                id: model.id,
                text: model.text,
                importance: Importance(rawValue: model.importance) ?? .basic,
                deadline: deadline,
                isDone: model.done,
                dateCreated: dateCreated,
                dateEdited: dateEdited,
                hexColor: model.color
            )
            
            todoItems.append(item)
        }

        return todoItems
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
                let todoItems = self.convertToViewModelFrom(serverModels)
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
                    self.view?.dismissSplashScreen()
                }
            }
        })
    }
    
    func syncTodoListWithServer(_ list: APIListResponse) {
        networkManager?.syncTodoList(list: list, completion: { result in
            switch result {
            case .success:
                SystemLogger.info("Синхронизация прошла успешно")
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
    }
    
    func sendTodoItemToServer(_ item: APIElementResponse) {
        networkManager?.sendTodoItem(item: item, completion: { result in
            switch result {
            case .success:
                SystemLogger.info("Сохранение подтверждено")
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
    }
    
    // TODO: () Пока никак не используется
    func getTodoItemFromServer(_ id: String) {
        networkManager?.getTodoItem(id: id, completion: { result in
            switch result {
            case .success(let serverModel):
                SystemLogger.info("\(serverModel)")
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
    }
    
    func updateTodoItemOnServer(_ item: APIElementResponse) {
        networkManager?.updateTodoItem(item: item, completion: { result in
            switch result {
            case .success:
                SystemLogger.info("Обновление подтверждено")
            case .failure(let error):
                SystemLogger.error(error.describing)
            }
        })
    }
    
    func deleteTodoItemFromServer(_ id: String) {
        networkManager?.deleteTodoItem(id: id, completion: { result in
            switch result {
            case .success:
                SystemLogger.info("Удаление подтверждено")
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
        
        let serverModel = convertToServerModel(todoItem)
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
            // TODO: () Перенести логику по сохранению на главный экран
            // а экран редактирования оставить так, чтобы он ничего не делал с
            // памятью и только брал данные из кеша. То есть по колбеку вызывать
            // не обновление массива, а производить сохранение, удаление и т.д.
            self?.getModels()
            
            // TODO: () временное решение для отправки новых данных на сервер
            // после создания менеджера работы с данными, удалить и выполнять
            // синхронизацию так, как это написанро в ТЗ
            // в текущем виде данные из заметки не обновляются
            if let models = self?.viewModels {
                let serverData = self?.convertModelsToServerModel(models)
                guard let serverData else { return }
                self?.syncTodoListWithServer(serverData)
            }
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
