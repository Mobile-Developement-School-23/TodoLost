//
//  TaskCell.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

final class TaskCell: UITableViewCell, IdentifiableCell {
    
    // MARK: - Private properties
    
    /// Хранит статус задачи
    /// Используется для изменения цвета изображения при переключении темы
    private var status: StatusTask = .statusDefault
    
    private let statusImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()
    
    private let titleHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    private let priorityImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = Colors.labelTertiary
        view.isHidden = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.body
        label.textColor = Colors.labelPrimary
        label.numberOfLines = 3
        return label
    }()
    
    private let descriptionHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    private let calendarImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = Icons.calendar.imageTemplate
        view.tintColor = Colors.labelTertiary
        view.isHidden = true
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.subhead
        label.textColor = Colors.labelTertiary
        label.isHidden = true
        return label
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
        
        statusImageView.image = nil
        titleLabel.attributedText = NSAttributedString("")
        titleLabel.textColor = Colors.labelPrimary
        subtitleLabel.text = ""
        priorityImageView.isHidden = true
        subtitleLabel.isHidden = true
        calendarImageView.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        statusImageView.image = status.imageStatus
        calendarImageView.tintColor = Colors.labelTertiary
    }
    
    // MARK: - Private methods
    
}

// MARK: - Public methods

extension TaskCell {
    func config(
        status: StatusTask,
        title: String,
        subtitle: String?
    ) {
        self.status = status
        statusImageView.image = status.imageStatus
        titleLabel.text = title
        
        switch status {
        case .statusDefault:
            break
        case .statusHigh:
            priorityImageView.image = Icons.highImportance.image
            priorityImageView.isHidden = false
        case .statusDone:
            let attributedString = NSAttributedString(
                string: title,
                attributes: [
                    NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )
            
            titleLabel.attributedText = attributedString
            titleLabel.textColor = Colors.labelTertiary
        case .statusLow:
            priorityImageView.image = Icons.lowImportance.image
            priorityImageView.isHidden = false
        }
        
        if subtitle != nil {
            calendarImageView.isHidden = false
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
        }
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
        separatorInset = Constants.separatorOffset
    }
    
    func addViews() {
        contentView.addSubview(statusImageView)
        contentView.addSubview(vStackView)
        
        vStackView.addArrangedSubview(titleHStackView)
        titleHStackView.addArrangedSubview(priorityImageView)
        titleHStackView.addArrangedSubview(titleLabel)
        
        vStackView.addArrangedSubview(descriptionHStackView)
        descriptionHStackView.addArrangedSubview(calendarImageView)
        descriptionHStackView.addArrangedSubview(subtitleLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 56
            ),
            
            // MARK: Status image
            
            statusImageView.heightAnchor.constraint(
                equalToConstant: Constants.statusCircle
            ),
            statusImageView.centerYAnchor.constraint(
                equalTo: vStackView.centerYAnchor
            ),
            statusImageView.widthAnchor.constraint(
                equalToConstant: Constants.statusCircle
            ),
            statusImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.paddingContent
            ),
            
            // MARK: VStack
            
            vStackView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            vStackView.topAnchor.constraint(
                greaterThanOrEqualTo: contentView.topAnchor,
                constant: Constants.paddingContent
            ),
            vStackView.leadingAnchor.constraint(
                equalTo: statusImageView.trailingAnchor,
                constant: Constants.vStackPadding
            ),
            vStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.paddingContent
            ),
            vStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -Constants.paddingContent
            )
        ])
    }
}

// MARK: - Constants

private extension TaskCell {
    struct Constants {
        static let paddingContent: CGFloat = 16
        static let vStackPadding: CGFloat = 12
        static let statusCircle: CGFloat = 24
        static let heightVStack: CGFloat = 24
        static let separatorOffset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
    }
}
