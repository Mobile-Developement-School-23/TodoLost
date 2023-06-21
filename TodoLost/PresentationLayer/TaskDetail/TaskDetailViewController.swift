//
//  TaskDetailViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit

/// Протокол отображения данных ViewCintroller-a
protocol TaskDetailView: AnyObject {
    
}

final class TaskDetailViewController: UIViewController {
    
    // MARK: - Public property
    
    var presenter: TaskDetailPresenter?
    
    // MARK: - Private property
    
    private var deadlineDay: String? = "234 345 345"
    private var isCalendarHidden = true
    /// Время выполнения анимаций на экране
    private let duration = 0.3
    
    private lazy var endEditingGesture: UIGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        return tapGesture
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = Colors.backPrimary
        return scrollView
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var textEditorTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = Colors.backSecondary
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        textView.font = Fonts.body
        return textView
    }()
    
    private var taskSettingsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.backSecondary
        view.layer.cornerRadius = 16
        return view
    }()
    
    private var importanceSettingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var importanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Важность"
        label.font = Fonts.body
        return label
    }()
    
    private lazy var importanceSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let lowImage = Icons.lowImportance.image
        let highImage = Icons.highImportance.image
        
        let normalLabel = UILabel()
        normalLabel.text = "нет"
        
        segmentedControl.insertSegment(with: lowImage, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: normalLabel.text, at: 1, animated: false)
        segmentedControl.insertSegment(with: highImage, at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 1
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        return segmentedControl
    }()
    
    private var separator1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.supportOverlay
        return view
    }()
    
    private var deadlineSettingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()
    
    private var deadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сделать до"
        label.font = Fonts.body
        return label
    }()
    
    private lazy var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.text = deadlineDay
        label.font = Fonts.footnote
        label.textColor = Colors.blue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deadlineDateTapped))
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var deadlineSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.addTarget(self, action: #selector(deadlineSwitchValueChanged), for: .valueChanged)
        return uiSwitch
    }()
    
    private var separator2: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.supportOverlay
        return view
    }()
    
    private var calendarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private var calendarView: UICalendarView = {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.isHidden = true
        calendarView.availableDateRange = DateInterval(start: .now, end: .distantFuture)
        return calendarView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(Colors.labelTertiary, for: .normal)
        button.backgroundColor = Colors.backSecondary
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textEditorTextView.delegate = self // сделать делегатом презентер
        setup()
        
    }
    
    // MARK: - Private methods
    private func setChoiceDateDefault() {
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        
        let year = components.year
        let month = components.month
        let day = (components.day ?? 0) + 1
        
        dateSelection.selectedDate = DateComponents(calendar: Calendar(identifier: .gregorian), year: year, month: month, day: day)
        calendarView.selectionBehavior = dateSelection
        deadlineDay = dateSelection.selectedDate?.date?.toString(format: "dd MMMM yyyy")
    }
    
    // MARK: - Actions
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func deadlineSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.deadlineDateLabel.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.deadlineDateLabel.isHidden = false
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.deadlineDateLabel.alpha = 1
                }
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.deadlineDateLabel.isHidden = true
            }
            
            hideCalendarAnimate(duration: duration)
        }
    }
    
    @objc private func deadlineDateTapped() {
        
        if isCalendarHidden {
            showCalendarAnimate(duration: duration)
        } else {
            hideCalendarAnimate(duration: duration)
        }
    }
    
    private func showCalendarAnimate(duration: CGFloat) {
        UIView.animate(withDuration: duration) {
            self.calendarView.isHidden = false
            self.separator2.isHidden = false
        } completion: { _ in
            UIView.animate(withDuration: duration) {
                self.calendarView.alpha = 1
            }
            
            self.isCalendarHidden = false
        }
    }
    
    private func hideCalendarAnimate(duration: CGFloat) {
        UIView.animate(withDuration: duration) {
            self.calendarView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: duration) {
                self.calendarView.isHidden = true
                self.separator2.isHidden = true
            }
            
            self.isCalendarHidden = true
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: print("Выбран сегмент 0")
        case 1: print("Выбран сегмент 1")
        case 2: print("Выбран сегмент 2")
        default:
            break
        }
    }
    
    @objc private func deleteButtonPressed() {
        print("Нажата кнопка удаления")
    }
}

// MARK: - Логика обновления данных View

extension TaskDetailViewController: TaskDetailView {
    
}

// MARK: - Конфигурирование ViewController

private extension TaskDetailViewController {
    /// Метод инициализации VC
    func setup() {
        setChoiceDateDefault()
        setupConstraints()
        
        view.addGestureRecognizer(endEditingGesture)
        
        title = "Дело"
        
        if textEditorTextView.text.isEmpty {
            textEditorTextView.text = "Что надо сделать?"
            textEditorTextView.textColor = Colors.labelTertiary
        } else {
            textEditorTextView.textColor = Colors.labelPrimary
        }
    }
    
    func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(textEditorTextView)
        
        containerView.addSubview(taskSettingsView)
        taskSettingsView.addSubview(importanceSettingView)
        importanceSettingView.addSubview(importanceLabel)
        importanceSettingView.addSubview(importanceSegmentedControl)
        
        containerView.addSubview(separator1)
        
        containerView.addSubview(deadlineStackView)
        taskSettingsView.addSubview(deadlineSettingView)
        deadlineSettingView.addSubview(deadlineStackView)
        deadlineStackView.addArrangedSubview(deadlineLabel)
        deadlineStackView.addArrangedSubview(deadlineDateLabel)
        deadlineSettingView.addSubview(deadlineSwitch)
        
        taskSettingsView.addSubview(calendarStackView)
        calendarStackView.addArrangedSubview(separator2)
        calendarStackView.addArrangedSubview(calendarView)
        
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            
            textEditorTextView.heightAnchor.constraint(equalToConstant: 120),
            textEditorTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            textEditorTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textEditorTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            taskSettingsView.topAnchor.constraint(equalTo: textEditorTextView.bottomAnchor, constant: 16),
            taskSettingsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            taskSettingsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            importanceSettingView.heightAnchor.constraint(equalToConstant: 56),
            importanceSettingView.topAnchor.constraint(equalTo: taskSettingsView.topAnchor),
            importanceSettingView.leadingAnchor.constraint(equalTo: taskSettingsView.leadingAnchor),
            importanceSettingView.trailingAnchor.constraint(equalTo: taskSettingsView.trailingAnchor),
            
            importanceLabel.centerYAnchor.constraint(equalTo: importanceSettingView.centerYAnchor),
            importanceLabel.leadingAnchor.constraint(equalTo: importanceSettingView.leadingAnchor, constant: 16),
            
            importanceSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
            importanceSegmentedControl.widthAnchor.constraint(equalToConstant: 150),
            importanceSegmentedControl.centerYAnchor.constraint(equalTo: importanceSettingView.centerYAnchor),
            importanceSegmentedControl.trailingAnchor.constraint(equalTo: importanceSettingView.trailingAnchor, constant: -16),
            
            separator1.heightAnchor.constraint(equalToConstant: 1),
            separator1.leadingAnchor.constraint(equalTo: importanceSettingView.leadingAnchor, constant: 16),
            separator1.trailingAnchor.constraint(equalTo: importanceSettingView.trailingAnchor, constant: -16),
            separator1.bottomAnchor.constraint(equalTo: importanceSettingView.bottomAnchor),
            
            deadlineSettingView.heightAnchor.constraint(equalToConstant: 56),
            deadlineSettingView.topAnchor.constraint(equalTo: separator1.bottomAnchor),
            deadlineSettingView.leadingAnchor.constraint(equalTo: taskSettingsView.leadingAnchor),
            deadlineSettingView.trailingAnchor.constraint(equalTo: taskSettingsView.trailingAnchor),

            deadlineStackView.centerYAnchor.constraint(equalTo: deadlineSettingView.centerYAnchor),
            deadlineStackView.leadingAnchor.constraint(equalTo: deadlineSettingView.leadingAnchor, constant: 16),

            deadlineSwitch.centerYAnchor.constraint(equalTo: deadlineSettingView.centerYAnchor),
            deadlineSwitch.trailingAnchor.constraint(equalTo: deadlineSettingView.trailingAnchor, constant: -16),
            
            separator2.heightAnchor.constraint(equalToConstant: 1),
            
            calendarStackView.topAnchor.constraint(equalTo: deadlineSettingView.bottomAnchor),
            calendarStackView.leadingAnchor.constraint(equalTo: deadlineSettingView.leadingAnchor, constant: 16),
            calendarStackView.trailingAnchor.constraint(equalTo: deadlineSettingView.trailingAnchor, constant: -16),
            calendarStackView.bottomAnchor.constraint(equalTo: taskSettingsView.bottomAnchor),

            deleteButton.heightAnchor.constraint(equalToConstant: 56),
            deleteButton.topAnchor.constraint(equalTo: taskSettingsView.bottomAnchor, constant: 16),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            // ???: Что нужно сделать, чтобы это перестало ломать интерфейс.
//            deleteButton.bottomAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: -67)
        ])

    }
}

// перенести в презентер
extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !textView.text.isEmpty {
            textView.text = nil
            textView.textColor = Colors.labelPrimary
            
            UIView.transition(
                with: deleteButton,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: {
                    self.deleteButton.setTitleColor(Colors.red, for: .normal)
                }
            ) { _ in
                self.deleteButton.isEnabled = true
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = Colors.labelTertiary
            
            UIView.transition(
                with: deleteButton,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: {
                    self.deleteButton.setTitleColor(Colors.labelTertiary, for: .normal)
                }
            ) { _ in
                self.deleteButton.isEnabled = false
            }
        }
    }
}

// MARK: CalendarView
extension TaskDetailViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        
        deadlineDateLabel.text = dateComponents?.date?.toString(format: "dd MMMM yyyy")
        
    }
}
