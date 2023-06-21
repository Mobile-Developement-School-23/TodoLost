//
//  Date+DateFormatter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 20.06.2023.
//

import Foundation

extension Date {
    func toString(format: String = "dd MMMM yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
