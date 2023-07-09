//
//  TaskDetailPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit
import DTLogger

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskDetailPresentationLogic: AnyObject,
                                      UITextViewDelegate,
                                      UICalendarSelectionSingleDateDelegate {
    init(view: TaskDetailView)
    
    /// Используется для уведомления предыдущего контроллера, о том что сохранение или удаление
    /// прошло успешно.
    /// - После подтверждения, вызывает обновление модели на экране
    var completion: (() -> Void)? { get set }
    /// Используется для передачи ID итема и отображения его на экране.
    /// Если id равен пустой строке, то создаётся новая заметка.
    var itemID: String? { get set }
    
    func fetchTask()
    func saveTask()
    func deleteTask()
    /// Отменяет анимацию активити индикатора
    func cancelCreateTask() // TODO: () Костыль пока не будет доработана архитектура
    // Пока нет единого менеджера работы с данными
    
    func updateViewModel(_ importance: Importance)
    func setDeadlineForViewModel()
    func clearDeadlineFromViewModel()
    
    func openColorPickerVC()
    
    func sendTodoItemToServer(_ item: APIElementResponse)
    func updateTodoItemOnServer(_ item: APIElementResponse)
    func deleteTodoItemFromServer(_ id: String)
    func syncTodoListWithServer(_ list: APIListResponse)
}

final class TaskDetailPresenter: NSObject {
    // MARK: - Architecture Properties
    
    weak var view: TaskDetailView?
    var router: TaskDetailRoutingLogic?
    
    // MARK: - Dependency properties
    
    // TODO: () Перенести логику по сохранению в менеджер работы с данными
    // чтобы вся работа с фаловой системой и сервером не была в логике презентера
    // сейчас из-за этого идёт дублирование кода в модуле списка и редактирования
    
    var fileCacheStorage: IFileCache?
    var networkManager: INetworkManager?
    var sqliteStorage: ISQLiteStorage?
    
    // MARK: - Public Properties
    
    var completion: (() -> Void)?
    var cancelCompletion: (() -> Void)?
    var itemID: String?
    
    // MARK: - Private properties
    
    private var viewModel: TaskDetailViewModel?
    
    // MARK: - Initializer
    
    required init(view: TaskDetailView) {
        self.view = view
    }
    
    // MARK: - Private methods
    
    /// Метод для получения объекта по ID
    /// - Returns: возвращает вью модель, если такая была найдена по ключу и ключ
    /// не был nil
    private func fetchTodoItemFromDB() -> TaskDetailViewModel? {
        var todoItem: TodoItem?
        do {
            todoItem = try sqliteStorage?.loadItem(id: itemID ?? "")
        } catch {
            SystemLogger.warning(error.localizedDescription)
        }
        
        guard let todoItem else { return nil }
        var viewModel = TaskDetailViewModel(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importance,
            deadline: todoItem.deadline,
            dateCreated: todoItem.dateCreated,
            isDone: todoItem.isDone
        )
        
        if let hexColor = todoItem.hexColor {
            viewModel.textColor = UIColor(hex: hexColor)
        }
    
        return viewModel
    }
    
    /// Метод для подготовки модели к синхронизации с сервером
    /// - Returns: <#description#>
    private func fetchModelsFromDBForServer() -> APIListResponse {
        var items: [TodoItem] = []
        
        do {
            let dbItems = try sqliteStorage?.load()
            if let dbItems {
                items.append(contentsOf: dbItems)
            }
        } catch {
            SystemLogger.error(error.localizedDescription)
        }
        
        return APIListResponse.convert(items)
    }
    
    /// Метод установки выбранной даты дедлайна в календарь
    /// - Parameter date: принимает дату, которая будет установлена как выбранная. Если даты нет
    /// будет установлен следующий день от текущего.
    /// - Так же создаёт модель
    private func setChoiceDateDeadline(date: Date?) {
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)

        let currentDate = date ?? Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        
        let year = components.year
        let month = components.month
        let day = date != nil ? components.day : (components.day ?? 0) + 1
        
        dateSelection.selectedDate = DateComponents(calendar: Calendar(identifier: .gregorian), year: year, month: month, day: day)
        
        if viewModel?.deadline != nil {
            viewModel?.deadline = dateSelection.selectedDate?.date
        }
        
        viewModel?.tempDeadline = dateSelection.selectedDate?.date
        
        view?.setDeadlineWith(dateSelection)
    }
    
    private func createNewTask() {
        return viewModel = TaskDetailViewModel(
            id: UUID().uuidString,
            text: "",
            importance: .basic,
            dateCreated: Date(),
            isDone: false
        )
    }
    
    private func handleColorSelection(hexColor: String) {
        viewModel?.textColor = UIColor(hex: hexColor)
        view?.updateView(viewModel)
        view?.activateSaveButton()
    }
}

// MARK: - Presentation Logic

extension TaskDetailPresenter: TaskDetailPresentationLogic {
    // MARK: Network requests
    
    func syncTodoListWithServer(_ list: APIListResponse) {
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
                
                SystemLogger.info("Синхронизация прошла успешно")
                
            case .failure(let error):
                SystemLogger.error(error.describing)
                // TODO: () Вывести алерт
            }
        })
    }
    
    func sendTodoItemToServer(_ item: APIElementResponse) {
        networkManager?.sendTodoItem(item: item, completion: { result in
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Сохранение подтверждено")
                } else {
                    // TODO: () Намеренный захват self чтобы сохранить класс живым,
                    // пока не будет закончена синхронизация. Будет исправлено
                    // при доработке архитектуры
                    let apiList = self.fetchModelsFromDBForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
                // TODO: () Вывести алерт
            }
        })
    }
    
    func updateTodoItemOnServer(_ item: APIElementResponse) {
        networkManager?.updateTodoItem(item: item, completion: { result in
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Обновление подтверждено")
                } else {
                    // TODO: () Намеренный захват self чтобы сохранить класс живым,
                    // пока не будет закончена синхронизация. Будет исправлено
                    // при доработке архитектуры
                    let apiList = self.fetchModelsFromDBForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
                // TODO: () Вывести алерт
            }
        })
    }
    
    func deleteTodoItemFromServer(_ id: String) {
        networkManager?.deleteTodoItem(id: id, completion: { result in
            switch result {
            case .success(let isDirty):
                if !isDirty {
                    SystemLogger.info("Удаление подтверждено")
                } else {
                    // TODO: () Намеренный захват self чтобы сохранить класс живым,
                    // пока не будет закончена синхронизация. Будет исправлено
                    // при доработке архитектуры
                    let apiList = self.fetchModelsFromDBForServer()
                    self.syncTodoListWithServer(apiList)
                }
            case .failure(let error):
                SystemLogger.error(error.describing)
                // TODO: () Вывести алерт
            }
        })
    }
    
    // MARK: Others
    
    /// Метод переводит временную дату дедлайна в постоянную
    /// - Используется в том случае, когда пользователь переключает свич установки дедлайна.
    /// Это необходимо для того, чтобы дедлайн правильно сохранился, если ранее он был nil
    func setDeadlineForViewModel() {
        let tempDeadline = viewModel?.tempDeadline
        viewModel?.deadline = tempDeadline
    }
    
    func clearDeadlineFromViewModel() {
        viewModel?.deadline = nil
    }
    
    func updateViewModel(_ importance: Importance) {
        viewModel?.importance = importance
    }
    
    func cancelCreateTask() {
        cancelCompletion?()
    }
    
    func saveTask() {
        guard let viewModel else { return }
        
        let todoItem = TodoItem(
            id: viewModel.id,
            text: viewModel.text,
            importance: viewModel.importance,
            deadline: viewModel.deadline,
            isDone: viewModel.isDone,
            dateCreated: viewModel.dateCreated,
            hexColor: viewModel.textColor?.toHexString()
        )
        
        do {
            try sqliteStorage?.insertOrReplace(item: todoItem)
        } catch {
            SystemLogger.error(error.localizedDescription)
            // TODO: () Вывести алерт
        }
        
        let serverModel = APIElementResponse.convert(todoItem)
        if itemID != nil && itemID != "" {
            updateTodoItemOnServer(serverModel)
        } else {
            sendTodoItemToServer(serverModel)
        }
        
        completion?()
    }
    
    func fetchTask() {
        viewModel = fetchTodoItemFromDB()
        if viewModel == nil {
            createNewTask()
        }
        setChoiceDateDeadline(date: viewModel?.deadline)
        view?.updateView(viewModel)
    }
    
    func deleteTask() {
        guard let id = viewModel?.id else {
            SystemLogger.warning("Модель не обновлена, ID нет")
            return
        }
        
        deleteTodoItemFromServer(id)
        
        do {
            try sqliteStorage?.delete(id: id)
            completion?()
        } catch {
            SystemLogger.error(error.localizedDescription)
            // TODO: () Вывести алерт
        }
    }
    
    // MARK: Navigation
    
    func openColorPickerVC() {
        router?.routeTo(target: .colorPicker) { [weak self] color in
            self?.handleColorSelection(hexColor: color)
        }
    }
}

// MARK: - UITextViewDelegate

extension TaskDetailPresenter: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != viewModel?.text && textView.text != "" {
            view?.activateSaveButton()
        } else {
            view?.deactivateSaveButton()
        }
        
        viewModel?.text = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.labelTertiary {
            view?.removePlaceholderToTextEditor()
            view?.activateDeleteButton()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            view?.setPlaceholderToTextEditor()
            view?.deactivateDeleteButton()
            view?.deactivateSaveButton()
        }
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate

extension TaskDetailPresenter: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        
        viewModel?.deadline = dateComponents?.date
        viewModel?.tempDeadline = dateComponents?.date
        view?.updateView(viewModel)
        view?.activateSaveButton()
    }
}
