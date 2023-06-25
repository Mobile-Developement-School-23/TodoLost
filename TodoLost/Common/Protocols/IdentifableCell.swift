//
//  IdentifableCell.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 25.06.2023.
//

protocol IdentifiableCell {}

extension IdentifiableCell {
    static var identifier: String {
        String(describing: Self.self)
    }
}
