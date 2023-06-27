//
//  TaskListSectionHeaderTableView.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 27.06.2023.
//

import UIKit

final class TaskListSectionHeaderTableView: UIView {
    
    var doneTaskCount = "0" {
        didSet {
            countLabel.text = doneTaskCount
        }
    }
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = doneTaskCount
        label.font = Fonts.subhead
        label.textColor = Colors.labelTertiary
        return label
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Colors.blue, for: .normal)
        button.titleLabel?.font = Fonts.footnote
        button.setTitle("Скрыть", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(countLabel)
        addSubview(toggleButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            countLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            toggleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleButton.leadingAnchor.constraint(greaterThanOrEqualTo: countLabel.trailingAnchor, constant: 16),
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
}
