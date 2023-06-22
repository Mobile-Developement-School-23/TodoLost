//
//  TaskDetailPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskDetailPresentationLogic: AnyObject, UITextViewDelegate {
    init(view: TaskDetailView)
    
    func fetchTask()
    func saveTask(item: TodoItem)
    func deleteTask(id: String)
}

final class TaskDetailPresenter: NSObject {
    // MARK: - Public Properties
    
    weak var view: TaskDetailView?
    
    var fileCacheStorage: IFileCache?
    
    // MARK: - Private properties
    
    private var currentText: String?
    
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
        currentText = item.text
        
        do {
            try fileCacheStorage?.saveToStorage(jsonFileName: "TodoList")
        } catch {
            // TODO: Вывести алерт
        }
    }
    
    func fetchTask() {
        let viewModel = loadDataFromStorage().first
        currentText = viewModel?.text
        view?.update(viewModel: viewModel)
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

// MARK: - UITextViewDelegate

extension TaskDetailPresenter: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != currentText {
            view?.activateSaveButton()
        } else {
            view?.deactivateSaveButton()
        }
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
        }
    }
}
