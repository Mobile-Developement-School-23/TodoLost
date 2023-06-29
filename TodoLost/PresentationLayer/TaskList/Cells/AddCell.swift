//
//  AddCell.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 29.06.2023.
//

import UIKit

final class AddCell: UITableViewCell, IdentifiableCell {
    
    // MARK: - Private properties
    
    private let addImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.body
        label.textColor = Colors.labelTertiary
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
        
        titleLabel.text = ""
        addImageView.image = nil
    }
    
    // MARK: - Private methods
    
}

// MARK: - Public methods

extension AddCell {
    func config(
        title: String = "Новое",
        image: UIImage? = Icons.add.image
    ) {
        titleLabel.text = title
        addImageView.image = image
    }
}

// MARK: - Configuration methods

private extension AddCell {
    func setup() {
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = Colors.backSecondary
        // Костыль чтобы скрыть разделитель у этой ячейки
        separatorInset = UIEdgeInsets(top: 0, left: .infinity, bottom: 0, right: 0)
    }
    
    func addViews() {
        contentView.addSubview(addImageView)
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 56
            ),
            
            // MARK: Add image
            
            addImageView.heightAnchor.constraint(
                equalToConstant: Constants.circle
            ),
            addImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            addImageView.widthAnchor.constraint(
                equalToConstant: Constants.circle
            ),
            addImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.paddingContent
            ),
            
            // MARK: Title Label
            
            titleLabel.leadingAnchor.constraint(
                equalTo: addImageView.trailingAnchor,
                constant: Constants.paddingBetweenElements
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }
}

// MARK: - Constants

private extension AddCell {
    struct Constants {
        static let paddingContent: CGFloat = 16
        static let paddingBetweenElements: CGFloat = 12
        static let circle: CGFloat = 24
    }
}
