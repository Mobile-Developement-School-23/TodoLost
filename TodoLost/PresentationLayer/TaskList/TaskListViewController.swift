//
//  TaskListViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit
import DTLogger

protocol TaskListHeaderDelegate: AnyObject {
    func toggleButtonTapped()
}

/// Протокол отображения данных ViewCintroller-a
protocol TaskListView: AnyObject {
    func presentPlaceholder()
    func hidePlaceholder()
    
    func display(models: [TaskViewModel], isShowComplete: Bool)
    func display(doneTaskCount: String, buttonTitle: String)
    
    func setSelectedCell(indexPath: IndexPath)
    
    func dismissSplashScreen()
    
    func startActivityAnimating()
    func stopActivityAnimating()
}

final class TaskListViewController: UIViewController {
    
    // MARK: - Public property
    
    var presenter: TaskListPresenter?
    var dataSourceProvider: ITaskListDataSourceProvider?
    var splashScreenPresenter: ISplashScreenPresenter?
    var transition: TransitionAnimationVC?
    
    // MARK: - Private property
    
    /// Используется для расчета анимации перехода, из какой ячейки её стартовать
    private var selectedIndexPath: IndexPath?
    /// Используется для расчета анимации, если была нажата кнопка, а не ячейка
    private var isAddButtonClicked = false
    
    // TODO: (FIX1) Подумать как решить проблему с ломающимися ячейками при добавлении и поворотах
    /// Используется для обновления отрисованных ячеек. Костыль для решения проблемы и борьба за дизайн  T_T
//    private var shouldReloadOnLayoutSubviews = false
    
    private var headerView: TaskListHeaderTableView?
    
    private var activityIndicator: HalfRingActivityIndicator = {
        let activityIndicator = HalfRingActivityIndicator()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
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
        
        splashScreenPresenter?.present()
        setup()
        
        presenter?.createDB()
        presenter?.getTodoListFromServer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupHeaderTableView()
    }
    
    // TODO: (FIX1) Подумать как решить проблему с ломающимися ячейками при добавлении и поворотах
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if shouldReloadOnLayoutSubviews {
//            tableView.reloadData()
//            shouldReloadOnLayoutSubviews = false
//        }
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        shouldReloadOnLayoutSubviews = true
//    }
    
    // MARK: - Actions
    
    @objc func addButtonPressed() {
        isAddButtonClicked = true
        presenter?.openDetailTaskVC(id: nil)
    }
}

// MARK: - Логика обновления данных View

extension TaskListViewController: TaskListView {
    func startActivityAnimating() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func stopActivityAnimating() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func dismissSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.splashScreenPresenter?.dismiss { [weak self] in
                self?.splashScreenPresenter = nil
            }
        }
    }
    
    func presentPlaceholder() {
        placeholderLabel.isHidden = false
    }
    
    func hidePlaceholder() {
        placeholderLabel.isHidden = true
    }
    
    func setSelectedCell(indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func display(models: [TaskViewModel], isShowComplete: Bool) {
        dataSourceProvider?.viewModels = models
        dataSourceProvider?.updateDataSource(isShowComplete)
    }
    
    func display(doneTaskCount: String, buttonTitle: String) {
        headerView?.doneTaskCount = doneTaskCount
        headerView?.buttonTitle = buttonTitle
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
        headerView = TaskListHeaderTableView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 32
            )
        )
        headerView?.sizeToFit()
        tableView.tableHeaderView = headerView
        
        headerView?.delegate = self
    }
    
    func registerElements() {
        tableView.register(
            TaskCell.self,
            forCellReuseIdentifier: TaskCell.identifier
        )
        
        tableView.register(
            AddCell.self,
            forCellReuseIdentifier: AddCell.identifier
        )
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
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
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            activityIndicator.centerYAnchor.constraint(equalTo: addButton.centerYAnchor, constant: -8),
            activityIndicator.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 60),
            activityIndicator.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - Constants

private extension TaskListViewController {
    struct Constants {
        static let buttonRectangle: CGFloat = 84
    }
}

// MARK: - TaskListHeaderDelegate

extension TaskListViewController: TaskListHeaderDelegate {
    func toggleButtonTapped() {
        presenter?.toggleVisibleTask()
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TaskListViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let transition else {
            SystemLogger.error("Не удалось инициализировать transition")
            return nil
        }
        
        if isAddButtonClicked {
            guard let buttonSuperview = addButton.superview else {
                transition.originFrame = .zero
                return nil
            }
            transition.originFrame = buttonSuperview.convert(addButton.frame, to: nil)
        } else {
            if let selectedIndexPath = selectedIndexPath,
               let selectedCell = tableView.cellForRow(at: selectedIndexPath) {
                transition.originFrame = selectedCell.convert(selectedCell.bounds, to: nil)
            }
        }
        
        transition.presenting = true
        
        return transition
    }
    
    // FIXME: Есть баг при скрытии контроллера в модальном режиме при кастомной анимации
    // Вью удаляется, а вью перехода остаются и блокирует взаимодействие с экраном
    // поэтому чтобы избежать проблем, временно возвращаю nil вместо transition
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // TODO: () Отрефакторить, сейчас дублируется кроме сброса isAddButtonClicked
        guard let transition else {
            SystemLogger.error("Не удалось инициализировать transition")
            return nil
        }
        
        if isAddButtonClicked {
            guard let buttonSuperview = addButton.superview else {
                transition.originFrame = .zero
                return nil
            }
            isAddButtonClicked = false
            transition.originFrame = buttonSuperview.convert(addButton.frame, to: nil)
        } else {
            if let selectedIndexPath = selectedIndexPath,
               let selectedCell = tableView.cellForRow(at: selectedIndexPath) {
                transition.originFrame = selectedCell.convert(selectedCell.bounds, to: nil)
            }
        }
        
        transition.presenting = false
        
        return nil
    }
}
