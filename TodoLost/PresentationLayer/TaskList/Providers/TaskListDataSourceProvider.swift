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
    // TODO: Будет использовано для пагинации как только появится работа с сервером
    /// Свойство для предотвращения попыток загрузки новых данных, если ничего нового загружено не было
//    private var loadedCount = 0
    
    // MARK: - Initializer
    
    init(presenter: TaskListPresenter) {
        self.presenter = presenter
    }
    
    // MARK: - Private methods
    
    // TODO: Будет использовано для пагинации как только появится работа с сервером
//    private func getNewModels() {
//        if viewModel.count != loadedCount {
//            presenter?.getServerData(offset: viewModel.count)
//            loadedCount += viewModel.count
//        }
//    }
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
                
                cell.config(title: model.id)
                
                return cell
            }
        )
    }
    
    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

// MARK: - Table view delegate

extension TaskListDataSourceProvider {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        // TODO: Будет использовано для будущей логики пагинации
//        if indexPath.row == viewModels.count - 1 {
//            getNewModels()
//        }
    }
}
