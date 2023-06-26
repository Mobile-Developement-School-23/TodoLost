//
//  TaskListViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

/// Протокол отображения данных ViewCintroller-a
protocol TaskListView: AnyObject {
    func display(models: [TaskViewModel])
}

final class TaskListViewController: UIViewController {
    
    // MARK: - Public property
    
    var presenter: TaskListPresenter?
    var dataSourceProvider: ITaskListDataSourceProvider?
    
    // MARK: - Private property
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.backPrimary
        return tableView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.getModels()
    }
    
    // MARK: - Actions
    
}

// MARK: - Логика обновления данных View

extension TaskListViewController: TaskListView {
    func display(models: [TaskViewModel]) {
        dataSourceProvider?.viewModels = models
        dataSourceProvider?.updateDataSource()
    }
}

// MARK: - Конфигурирование ViewController

private extension TaskListViewController {
    func setup() {
        view.backgroundColor = Colors.backPrimary
        
        setupNavigationController()
        setupTableView()
        setupConstraints()
    }
    
    func setupNavigationController() {
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupTableView() {
        registerElements()
        
        dataSourceProvider?.makeDataSource(with: tableView)
        tableView.delegate = dataSourceProvider
    }
    
    func registerElements() {
        tableView.register(
            TaskCell.self,
            forCellReuseIdentifier: TaskCell.identifier
        )
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
