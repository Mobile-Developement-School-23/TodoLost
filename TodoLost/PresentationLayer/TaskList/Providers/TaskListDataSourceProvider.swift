//
//  TaskListDataSourceProvider.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

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
    private var completedTaskModels: [TaskViewModel] = []
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
            completedTaskModels = viewModels.filter({ $0.status != .statusDone })
            snapshot.appendItems(completedTaskModels, toSection: .main)
        }
        
        dataSource?.defaultRowAnimation = .fade
        dataSource?.apply(snapshot, animatingDifferences: true, completion: nil)
        
        let completeCount = completedTaskModels.count
        presenter?.updateHeaderView(completeCount, buttonTitle: buttonTitle)
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
            viewModel = completedTaskModels[indexPath.row]
        }
        
        presenter?.openDetailTaskVC(id: viewModel?.id)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // TODO: написать код для скрытия кнопки
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // TODO: написать код для отображения кнопки
    }
}
