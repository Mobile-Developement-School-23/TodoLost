//
//  TaskDetailPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import Foundation

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskDetailPresentationLogic: AnyObject {
    init(view: TaskDetailView)
    
    func fetchTask()
    func saveTask(item: TodoItem)
    func deleteTask(id: String)
}

final class TaskDetailPresenter {
    // MARK: - Public Properties
    
    weak var view: TaskDetailView?
    
    var fileCacheStorage: IFileCache?
    
    // MARK: - Private properties
    
    // MARK: - Initializer
    
    required init(view: TaskDetailView) {
        self.view = view
    }
    
    // MARK: - Private methods
    
    private func loadDataFromStorage() -> [TaskDetailViewModel] {
        var viewModels: [TaskDetailViewModel] = []
        
        do {
            try fileCacheStorage?.loadFromStorage(jsonFileName: "TodoList")
        } catch {
            print(error.localizedDescription)
        }
        
        fileCacheStorage?.items.forEach({ (_, value) in
            let viewModel = TaskDetailViewModel(
                id: value.id,
                text: value.text,
                importance: value.importance,
                deadline: value.deadline
            )
            
            viewModels.append(viewModel)
        })
        
        return viewModels
    }
}

// MARK: - Presentation Logic

extension TaskDetailPresenter: TaskDetailPresentationLogic {
    func saveTask(item: TodoItem) {
        fileCacheStorage?.addToCache(item)
        
        do {
            try fileCacheStorage?.saveToStorage(jsonFileName: "TodoList")
        } catch {
            // TODO: Вывести алерт
        }
        
    }
    
    func fetchTask() {
        let viewModels = loadDataFromStorage()
        view?.update(viewModel: viewModels.first)
    }
    
    func deleteTask(id: String) {
        fileCacheStorage?.deleteFromCache(id)
        do {
            try fileCacheStorage?.saveToStorage(jsonFileName: "TodoList")
        } catch {
            // TODO: Вывести алерт
        }
    }
}
