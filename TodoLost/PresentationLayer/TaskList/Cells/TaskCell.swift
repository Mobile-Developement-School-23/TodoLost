//
//  TaskCell.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

import UIKit

final class TaskCell: UITableViewCell, IdentifiableCell {
    
    // MARK: - Private properties
    
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
    func config() {
        
    }
}

// MARK: - Configuration methods

private extension TaskCell {
    func setup() {
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
    }
    
    func addViews() {
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
        ])
    }
}

// MARK: - Constants
private extension TaskCell {
    struct Constants {
        
    }
}

