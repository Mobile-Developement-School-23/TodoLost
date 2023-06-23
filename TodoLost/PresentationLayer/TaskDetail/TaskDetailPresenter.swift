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
    
    func fetchTask()
    func saveTask()
    func deleteTask()
    
    func updateViewModel(_ importance: Importance)
    func setDeadlineForViewModel()
    func clearDeadlineFromViewModel()
    
    func openColorPickerVC()
}

final class TaskDetailPresenter: NSObject {
    // MARK: - Public Properties
    
    weak var view: TaskDetailView?
    var router: TaskDetailRoutingLogic?
    
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
            SystemLogger.error(error.localizedDescription)
        }
        
        fileCacheStorage?.items.forEach({ (_, value) in
            viewModel = TaskDetailViewModel(
                id: value.id,
                text: value.text,
                importance: value.importance,
                deadline: value.deadline
            )
            
            if let hexColor = value.hexColor {
                viewModel?.textColor = UIColor(hex: hexColor)
            }
            
            guard let viewModel else { return }
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
                importance: .normal
            )
        } else if viewModel?.deadline != nil {
            viewModel?.deadline = dateSelection.selectedDate?.date
        }
        
        viewModel?.tempDeadline = dateSelection.selectedDate?.date
        
        view?.setDeadlineWith(dateSelection)
    }
    
    private func handleColorSelection(hexColor: String) {
        viewModel?.textColor = UIColor(hex: hexColor)
        view?.updateView(viewModel)
    }
}

// MARK: - Presentation Logic

extension TaskDetailPresenter: TaskDetailPresentationLogic {
    func openColorPickerVC() {
        router?.routeTo(target: .colorPicker) { [weak self] color in
            self?.handleColorSelection(hexColor: color)
        }
    }
    
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
    
    func saveTask() {
        guard let viewModel else { return }
        
        let todoItem = TodoItem(
            id: viewModel.id,
            text: viewModel.text,
            importance: viewModel.importance,
            deadline: viewModel.deadline,
            isDone: false,
            hexColor: viewModel.textColor?.toHexString()
        )
        
        fileCacheStorage?.addToCache(todoItem)
        
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
    
    func deleteTask() {
        guard let id = viewModel?.id else {
            SystemLogger.warning("Модель не обновлена, ID нет")
            return
        }
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
