//
//  ColorPickerViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 23.06.2023.
//

import UIKit
import DTLogger
import ColorWheel

/// Протокол отображения данных ViewCintroller-a
protocol ColorPickerView: AnyObject {
    
}

final class ColorPickerViewController: UIViewController {
    
    // MARK: - Public property
    
    var completion: ((String) -> Void)?
    var presenter: ColorPickerPresenter?
    
    // MARK: - Private property
    
    private let colorView: ColorWheel = {
        let view = ColorWheel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.backPrimary
        return view
    }()
    
    private let colorHexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "#000000"
        label.font = Fonts.body
        return label
    }()
    
    private let selectedColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.labelTertiary?.cgColor
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Выбрать", for: .normal)
        button.setTitleColor(Colors.blue, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = Colors.backSecondary
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(selectColor))
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        colorView.layer.cornerRadius = colorView.frame.width / 2
    }
    
    // MARK: - Actions
    
    @objc private func selectColor(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: colorView)
        let color = colorView.colorAtPoint(point: location)
        selectedColorView.backgroundColor = color
        
        let hexString = color.toHexString()
        colorHexLabel.text = hexString
    }
    
    @objc func doneButtonPressed() {
        guard let hexColor = colorHexLabel.text else {
            SystemLogger.error("HEX код цвета не передан")
            return
        }
        
        completion?(hexColor)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Логика обновления данных View

extension ColorPickerViewController: ColorPickerView {
    
}

// MARK: - Конфигурирование ViewController

private extension ColorPickerViewController {
    func setup() {
        view.backgroundColor = Colors.backPrimary
        
        colorView.addGestureRecognizer(panGestureRecognizer)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        view.addSubview(colorView)
        view.addSubview(colorHexLabel)
        view.addSubview(selectedColorView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            selectedColorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            selectedColorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedColorView.heightAnchor.constraint(equalToConstant: 50),
            selectedColorView.widthAnchor.constraint(equalTo: selectedColorView.heightAnchor),
            
            colorHexLabel.centerYAnchor.constraint(equalTo: selectedColorView.centerYAnchor),
            colorHexLabel.leadingAnchor.constraint(equalTo: selectedColorView.trailingAnchor, constant: 10),
            
            colorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 350),
            colorView.widthAnchor.constraint(equalToConstant: 350),
            
            doneButton.heightAnchor.constraint(equalToConstant: 65),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -65)
        ])
    }
}
