//
//  TaskListViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

/// Протокол отображения данных ViewCintroller-a
protocol TaskListView: AnyObject {
    func presentPlaceholder()
    func hidePlaceholder()
    
    func display(models: [TaskViewModel])
    func display(doneTaskCount: String)
}

final class TaskListViewController: UIViewController {
    
    // MARK: - Public property
    
    var presenter: TaskListPresenter?
    var dataSourceProvider: ITaskListDataSourceProvider?
    
    // MARK: - Private property
    
    private lazy var headerView = TaskListSectionHeaderTableView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.backPrimary
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let image = Icons.addPlusButton.image
        button.setImage(image, for: .normal)
        
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.labelTertiary
        label.font = Fonts.body
        label.text = "У вас нет созданных заметок"
        label.isHidden = true
        return label
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupHeaderTableView()
        presenter?.getModels()
    }
    
    // MARK: - Actions
    
    @objc func addButtonPressed() {
        presenter?.openDetailTaskVC(id: nil)
    }
}

// MARK: - Логика обновления данных View

extension TaskListViewController: TaskListView {
    func presentPlaceholder() {
        placeholderLabel.isHidden = false
    }
    
    func hidePlaceholder() {
        placeholderLabel.isHidden = true
    }
    
    func display(models: [TaskViewModel]) {
        dataSourceProvider?.viewModels = models
        dataSourceProvider?.updateDataSource()
    }
    
    func display(doneTaskCount: String) {
        headerView.doneTaskCount = doneTaskCount
        headerView.setNeedsDisplay()
        tableView.reloadData()
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
        
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 32,
            bottom: 0,
            right: 0
        )
    }
    
    func setupTableView() {
        registerElements()
        
        dataSourceProvider?.makeDataSource(with: tableView)
        tableView.delegate = dataSourceProvider
    }
    
    func setupHeaderTableView() {
        headerView = TaskListSectionHeaderTableView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 32
            )
        )
        headerView.sizeToFit()
        tableView.tableHeaderView = headerView
    }
    
    func registerElements() {
        tableView.register(
            TaskCell.self,
            forCellReuseIdentifier: TaskCell.identifier
        )
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonRectangle),
            addButton.widthAnchor.constraint(equalToConstant: Constants.buttonRectangle),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
}

// MARK: - Constants

private extension TaskListViewController {
    struct Constants {
        static let buttonRectangle: CGFloat = 84
    }
}
