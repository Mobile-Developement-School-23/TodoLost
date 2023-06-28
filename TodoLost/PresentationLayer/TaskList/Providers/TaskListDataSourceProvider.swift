//
//  TaskListDataSourceProvider.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit
import DTLogger

protocol ITaskListDataSourceProvider: UITableViewDelegate {
    var viewModels: [TaskViewModel] { get set}
    func makeDataSource(with tableView: UITableView)
    func updateDataSource(_ showComplete: Bool)
}

final class TaskListDataSourceProvider: NSObject, ITaskListDataSourceProvider {
    
    // MARK: - Public properties
    
    var viewModels: [TaskViewModel] = []
    
    // MARK: - Private properties
    
    private let presenter: TaskListPresenter?
    private var dataSource: UITableViewDiffableDataSource<Section, TaskViewModel>?
    
    // MARK: - Initializer
    
    init(presenter: TaskListPresenter) {
        self.presenter = presenter
    }
    
    // MARK: - Private methods
    
    private var isShowComplete = false
    private var notCompletedTaskModels: [TaskViewModel] = []
}

// MARK: - Table view data source

extension TaskListDataSourceProvider {
    enum Section {
        case main
    }
    
    func makeDataSource(with cardsTableView: UITableView) {
        dataSource = UITableViewDiffableDataSource(
            tableView: cardsTableView,
            cellProvider: { tableView, indexPath, model -> UITableViewCell? in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: TaskCell.identifier,
                    for: indexPath
                ) as? TaskCell else {
                    return UITableViewCell()
                }
                
                cell.config(
                    status: model.status,
                    title: model.title,
                    subtitle: model.subtitle
                )
                
                return cell
            }
        )
    }
    
    func updateDataSource(_ showComplete: Bool) {
        var buttonTitle = "Показать"
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskViewModel>()
        snapshot.appendSections([.main])
        
        if showComplete {
            isShowComplete = true
            snapshot.appendItems(viewModels, toSection: .main)
            buttonTitle = "Скрыть"
        } else {
            isShowComplete = false
            notCompletedTaskModels = viewModels.filter({ $0.status != .statusDone })
            snapshot.appendItems(notCompletedTaskModels, toSection: .main)
        }
        
        // ???: Может ли подобное вызвать цикл сильной ссылки или оно работает как и с анимацией и можно не использовать weak self?
        dataSource?.apply(snapshot, animatingDifferences: true, completion: {
            let completeCount = self.viewModels.filter({ $0.status == .statusDone }).count
            self.presenter?.updateHeaderView(completeCount, buttonTitle: buttonTitle)
        })
    }
}

// MARK: - Table view delegate

extension TaskListDataSourceProvider {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var viewModel: TaskViewModel?
        
        if isShowComplete {
            viewModel = viewModels[indexPath.row]
        } else {
            viewModel = notCompletedTaskModels[indexPath.row]
        }
        
        presenter?.openDetailTaskVC(id: viewModel?.id)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        var viewModel: TaskViewModel?
        
        if isShowComplete {
            viewModel = viewModels[indexPath.row]
        } else {
            viewModel = notCompletedTaskModels[indexPath.row]
        }
        
        guard let viewModel else {
            SystemLogger.error("Не удалось получить модель")
            return nil
        }
        
        let deleteAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { [weak self] _, _, isDone in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.presenter?.delete(viewModel)
            }
            
            isDone(true)
        }
        
        let infoAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { _, _, isDone in
            // TODO: добавить действие для кнопки info. Например вывести дату создания заметки
            SystemLogger.info(viewModel.dateCreated.description)
            isDone(true)
        }
        
        deleteAction.backgroundColor = Colors.red
        deleteAction.image = Icons.trash.image
        
        infoAction.backgroundColor = Colors.grayLight
        infoAction.image = Icons.info.image
        
        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction, infoAction]
        )
        
        return configuration
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        var viewModel: TaskViewModel?
        
        if isShowComplete {
            viewModel = viewModels[indexPath.row]
        } else {
            viewModel = notCompletedTaskModels[indexPath.row]
        }
        
        guard let viewModel else {
            SystemLogger.error("Не удалось получить модель")
            return nil
        }
        
        let completeAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { [weak self] _, _, isDone in
            
            // ???: Это костыль или нормальный подход для того чтобы не вызвать раньше времени обновление таблицы и дать анимации плавно закончится?
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.presenter?.setIsDone(viewModel)
            }
            
            isDone(true)
        }
        
        completeAction.backgroundColor = Colors.green
        completeAction.image = Icons.completion.image
        
        let configuration = UISwipeActionsConfiguration(
            actions: [completeAction]
        )
        
        return configuration
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // TODO: написать код для скрытия кнопки
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // TODO: написать код для отображения кнопки
    }
}
