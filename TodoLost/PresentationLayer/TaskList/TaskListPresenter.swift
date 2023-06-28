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
    /// Открывает новый контроллер с текущей заметкой
    /// - Parameter id: если ID nil, откроется экран для создания новой заметки
    func openDetailTaskVC(id: String?)
    func updateHeaderView(_ doneTaskCount: Int, buttonTitle: String)
    
    func toggleVisibleTask()
}

final class TaskListPresenter {
    
    // MARK: - Public Properties
    
    weak var view: TaskListView?
    var router: TaskListRoutingLogic?
    
    var fileCacheStorage: IFileCache?
    /// СОбирается в конфигураторе и используется для делегирования нажатия на кнопку
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
    
    private func fetchModelsFromCache() -> [TaskViewModel] {
        if let items = fileCacheStorage?.items {
            if items.isEmpty {
                loadDataFromStorage()
            }
        }
        
        var viewModels: [TaskViewModel] = []
        
        fileCacheStorage?.items.forEach({ (_, value) in
            
            // TODO: ВОзможно стоит хранить какой то статус по умолчанию в классе
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
                subtitle: value.deadline?.toString(format: "dd MMMM")
            )

            viewModels.append(viewModel)
        })
        
        return viewModels
    }
}

// MARK: - Presentation Logic

extension TaskListPresenter: TaskListPresentationLogic {
    func toggleVisibleTask() {
        isShowComplete.toggle()
        view?.display(models: viewModels, isShowComplete: isShowComplete)
    }
    
    func updateHeaderView(_ doneTaskCount: Int, buttonTitle: String) {
        view?.display(doneTaskCount: "Выполнено — \(doneTaskCount)", buttonTitle: buttonTitle)
    }
    
    // ???: Нормально ли использовать такой подход с комплишином который передаётся через роутер, чтобы я мог обработать завершение сохранения и обновить данные в таблице?
    func openDetailTaskVC(id: String?) {
        router?.routeTo(target: .taskDetail(id)) { [weak self] in
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
