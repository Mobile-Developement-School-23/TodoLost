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
    func updateDataSource()
}

final class TaskListDataSourceProvider: NSObject, ITaskListDataSourceProvider {
    
    // MARK: - Public properties
    
    var viewModels: [TaskViewModel] = []
    
    // MARK: - Private properties
    
    private let presenter: TaskListPresenter?
    private var dataSource: UITableViewDiffableDataSource<Section, TaskViewModel>?
    
//    private let headerView = TaskListSectionHeaderTableView()
    
    // MARK: - Initializer
    
    init(presenter: TaskListPresenter) {
        self.presenter = presenter
    }
    
    // MARK: - Private methods
    
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
    
    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: true, completion: nil)
        
        // TODO: Тут будет считаться массив, отфильтрованный по выполненным
        presenter?.updateHeaderView(viewModels.count)
    }
}

// MARK: - Table view delegate

extension TaskListDataSourceProvider {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presenter?.openDetailTaskVC(id: viewModels[indexPath.row].id)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // TODO: написать код для скрытия кнопки
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // TODO: написать код для отображения кнопки
    }
}
