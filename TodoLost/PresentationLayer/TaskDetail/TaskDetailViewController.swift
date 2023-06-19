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
    
    private lazy var endEditingGesture: UIGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        return tapGesture
    }()
    
    @UsesAutoLayout
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Colors.backPrimary
        return scrollView
    }()
    
    @UsesAutoLayout
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        return stackView
    }()
    
    private var textEditorTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = Colors.backSecondary
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        textView.font = Fonts.body
        return textView
    }()
    
    @UsesAutoLayout
    private var taskSettingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.backgroundColor = Colors.backSecondary
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    @UsesAutoLayout
    private var importanceSettingView: UIView = {
        let view = UIView()
        return view
    }()
    
    @UsesAutoLayout
    private var importanceLabel: UILabel = {
        let label = UILabel()
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
    
    @UsesAutoLayout
    private var separator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.supportOverlay
        return view
    }()
    
    @UsesAutoLayout
    private var deadlineSettingView: UIView = {
        let view = UIView()
        return view
    }()
    
    @UsesAutoLayout
    private var deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()
    
    private var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = Fonts.body
        return label
    }()
    
    private var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.text = "2 июня 2021"
        label.font = Fonts.footnote
        label.textColor = Colors.blue
        return label
    }()
    
    private lazy var deadlineSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.addTarget(self, action: #selector(deadlineSwitchValueChanged), for: .valueChanged)
        return uiSwitch
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
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
        setupConstraints()
        setup()
    }
    
    // MARK: - Actions
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func deadlineSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            print("Дедлайн активирован")
            
            self.deadlineDateLabel.alpha = 0
            self.deadlineDateLabel.isHidden = false
            
            self.deadlineStackView.addArrangedSubview(self.deadlineDateLabel)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.deadlineDateLabel.alpha = 1
                self.stackView.layoutIfNeeded()
            })
        } else {
            print("Дедлайн деактивирован")
            
            // Плейсхолдер используется для предотвращения резкой анимации при удалении
            let placeholderView = UIView()
            guard let dataLabelIndex = deadlineStackView.arrangedSubviews.firstIndex(of: deadlineDateLabel) else {
                debugPrint("Нет такого индекса для dataLabelIndex")
                return
            }
            
            self.deadlineStackView.insertArrangedSubview(placeholderView, at: dataLabelIndex)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.deadlineDateLabel.isHidden = true
                self.stackView.layoutIfNeeded()
            }) { _ in
                self.deadlineStackView.removeArrangedSubview(self.deadlineDateLabel)
                self.deadlineDateLabel.removeFromSuperview()
                placeholderView.removeFromSuperview()
            }
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
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(textEditorTextView)
        stackView.addArrangedSubview(taskSettingsStackView)
        stackView.addArrangedSubview(deleteButton)
        
        taskSettingsStackView.addArrangedSubview(importanceSettingView)
        importanceSettingView.addSubview(importanceLabel)
        importanceSettingView.addSubview(importanceSegmentedControl)
        importanceSettingView.addSubview(separator)
        
        
        taskSettingsStackView.addArrangedSubview(deadlineSettingView)
        deadlineSettingView.addSubview(deadlineStackView)
        deadlineStackView.addArrangedSubview(deadlineLabel)
        deadlineSettingView.addSubview(deadlineSwitch)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            textEditorTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            importanceSettingView.heightAnchor.constraint(equalToConstant: 56),
            
            importanceLabel.centerYAnchor.constraint(equalTo: importanceSettingView.centerYAnchor),
            importanceLabel.leadingAnchor.constraint(equalTo: importanceSettingView.leadingAnchor, constant: 16),
            
            importanceSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
            importanceSegmentedControl.widthAnchor.constraint(equalToConstant: 150),
            importanceSegmentedControl.centerYAnchor.constraint(equalTo: importanceSettingView.centerYAnchor),
            importanceSegmentedControl.trailingAnchor.constraint(equalTo: importanceSettingView.trailingAnchor, constant: -16),
            
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: importanceSettingView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: importanceSettingView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: importanceSettingView.bottomAnchor),
            
            deadlineSettingView.heightAnchor.constraint(equalToConstant: 56),
            
            deadlineStackView.centerYAnchor.constraint(equalTo: deadlineSettingView.centerYAnchor),
            deadlineStackView.leadingAnchor.constraint(equalTo: deadlineSettingView.leadingAnchor, constant: 16),
            
            deadlineSwitch.centerYAnchor.constraint(equalTo: deadlineSettingView.centerYAnchor),
            deadlineSwitch.trailingAnchor.constraint(equalTo: deadlineSettingView.trailingAnchor, constant: -16),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
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
