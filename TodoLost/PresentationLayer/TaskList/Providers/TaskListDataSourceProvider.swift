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
    
    private var isShowCompleted = false
    private var notCompletedTaskModels: [TaskViewModel] = []
    
    // MARK: - Private method
    
    private func fetchViewModelWith(_ indexPath: IndexPath) -> TaskViewModel? {
        var viewModel: TaskViewModel?
        
        if isShowCompleted {
            viewModel = viewModels[indexPath.row]
        } else {
            viewModel = notCompletedTaskModels[indexPath.row]
        }
        
        return viewModel
    }
}

// MARK: - Table view data source

extension TaskListDataSourceProvider {
    enum Section: Int {
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
            isShowCompleted = true
            snapshot.appendItems(viewModels, toSection: .main)
            buttonTitle = "Скрыть"
        } else {
            isShowCompleted = false
            notCompletedTaskModels = viewModels.filter({ $0.status != .statusDone })
            snapshot.appendItems(notCompletedTaskModels, toSection: .main)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true, completion: { [weak self] in
            guard let completedCount = self?.viewModels.filter({ $0.status == .statusDone }).count else {
                SystemLogger.error(Errors.errorCompletedTaskCount.localizedDescription)
                return
            }
            self?.presenter?.updateHeaderView(completedCount, buttonTitle: buttonTitle)
        })
    }
}

// MARK: - Table view delegate

extension TaskListDataSourceProvider {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var viewModel: TaskViewModel?
        
        if isShowCompleted {
            viewModel = viewModels[indexPath.row]
        } else {
            viewModel = notCompletedTaskModels[indexPath.row]
        }
        
        presenter?.setSelectedCell(indexPath: indexPath)
        presenter?.openDetailTaskVC(id: viewModel?.id)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let viewModel = fetchViewModelWith(indexPath)
        guard let viewModel else {
            SystemLogger.error(Errors.fetchError.localizedDescription)
            return nil
        }
        
        let deleteAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { [weak self] _, _, isDone in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
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
        
        let viewModel = fetchViewModelWith(indexPath)
        guard let viewModel else {
            SystemLogger.error(Errors.fetchError.localizedDescription)
            return nil
        }
        
        let completeAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { [weak self] _, _, isDone in
            
            // TODO: Подумать как это сделать без asyncAfter
            // Возможно DiffableDataSource не предполагает использование с UIContextualAction
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
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
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        let viewModel = fetchViewModelWith(indexPath)
        guard let viewModel else {
            SystemLogger.error(Errors.fetchError.localizedDescription)
            return nil
        }
        
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil
        ) { _ in
            
            var doneTitle: String?
            var doneImage: UIImage?
            
            if viewModel.isDone {
                doneTitle = "Не выполнено"
                doneImage = Icons.completion.image?.withTintColor(Colors.labelTertiary ?? UIColor.white)
            } else {
                doneTitle = "Выполнено"
                doneImage = Icons.completion.image?.withTintColor(Colors.green ?? UIColor.white)
            }
            
            let completeAction = UIAction(
                title: doneTitle ?? "",
                image: doneImage
            ) { [weak self] _ in
                self?.presenter?.setIsDone(viewModel)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: Icons.trash.imageTemplate?.withTintColor(Colors.red ?? UIColor.white),
                attributes: .destructive
            ) { [weak self] _ in
                self?.presenter?.delete(viewModel)
            }
            
            return UIMenu(
                title: "Выберите действие",
                options: .displayInline,
                preferredElementSize: .large,
                children: [completeAction, deleteAction]
            )
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        guard
            let identifier = configuration.identifier as? String,
            let index = Int(identifier)
        else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: Section.main.rawValue)
        
        let viewModel = fetchViewModelWith(indexPath)
        guard let viewModel else {
            SystemLogger.error(Errors.fetchError.localizedDescription)
            return
        }
        
        animator.addCompletion { [weak self] in
            self?.presenter?.openDetailTaskVC(id: viewModel.id)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // TODO: написать код для скрытия кнопки
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // TODO: написать код для отображения кнопки
    }
}

// MARK: - Errors

private extension TaskListDataSourceProvider {
    enum Errors: LocalizedError {
        case fetchError
        case errorCompletedTaskCount
        
        var errorDescription: String? {
            switch self {
            case .fetchError:
                return "Не удалось получить модель"
            case .errorCompletedTaskCount:
                return "Не удалось получить количество выполненных задач"
            }
        }
    }
}

