//
//  TaskCell.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

final class TaskCell: UITableViewCell, IdentifiableCell {
    
    // MARK: - Private properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.labelPrimary
        return label
    }()
    
    private let calendarImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.labelTertiary
        return label
    }()
    
    private let statusImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    // MARK: - Private methods
    
}

// MARK: - Public methods

extension TaskCell {
    func config(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Configuration methods

private extension TaskCell {
    func setup() {
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = Colors.backSecondary
        accessoryType = .disclosureIndicator
    }
    
    func addViews() {
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.paddingContent
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.paddingContent
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.paddingContent
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.paddingContent
            ),
        ])
    }
}

// MARK: - Constants
private extension TaskCell {
    struct Constants {
        static let paddingContent: CGFloat = 16
    }
}

