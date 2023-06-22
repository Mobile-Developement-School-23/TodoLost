//
//  TaskDetailPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit

/// Протокол взаимодействия ViewController-a с презенетром
protocol TaskDetailPresentationLogic: AnyObject,
                                      UITextViewDelegate,
                                      UICalendarSelectionSingleDateDelegate {
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
    
    private var viewModel: TaskDetailViewModel?
    
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
            viewModel = TaskDetailViewModel(
                id: value.id,
                text: value.text,
                importance: value.importance,
                deadline: value.deadline
            )
            guard let viewModel else {
                debugPrint("Нет моделей")
                return
            }
            viewModels.append(viewModel)
        })
        
        return viewModels
    }
    
    /// Метод установки выбранной даты дедлайна в календарь
    /// - Parameter date: принимает дату, которая будет установлена как выбранная. Если даты нет
    /// будет установлен следующий день от текущего.
    private func setChoiceDateDeadline(date: Date?) {
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)

        let currentDate = date ?? Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        
        let year = components.year
        let month = components.month
        let day = date != nil ? components.day : (components.day ?? 0) + 1
        
        dateSelection.selectedDate = DateComponents(calendar: Calendar(identifier: .gregorian), year: year, month: month, day: day)
        
        if viewModel == nil {
            viewModel = TaskDetailViewModel(
                id: UUID().uuidString,
                text: "",
                importance: .normal,
                tempDeadline: dateSelection.selectedDate?.date
            )
        } else {
            viewModel?.deadline = dateSelection.selectedDate?.date
            viewModel?.tempDeadline = dateSelection.selectedDate?.date
        }
        
        view?.setDeadlineWith(dateSelection)
    }
}

// MARK: - Presentation Logic

extension TaskDetailPresenter: TaskDetailPresentationLogic {
    func saveTask(item: TodoItem) {
        fileCacheStorage?.addToCache(item)
        viewModel?.text = item.text
        
        do {
            try fileCacheStorage?.saveToStorage(jsonFileName: "TodoList")
        } catch {
            // TODO: Вывести алерт
        }
    }
    
    func fetchTask() {
        if let model = loadDataFromStorage().first {
            viewModel = model
        }
        setChoiceDateDeadline(date: viewModel?.deadline)
        view?.updateView(viewModel)
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
        if textView.text != viewModel?.text {
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

// MARK: - UICalendarSelectionSingleDateDelegate

extension TaskDetailPresenter: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        
        viewModel?.deadline = dateComponents?.date
        viewModel?.tempDeadline = dateComponents?.date
        view?.updateView(viewModel)
        view?.activateSaveButton()
    }
}
