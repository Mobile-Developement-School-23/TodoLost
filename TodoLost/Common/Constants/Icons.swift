//
//  Icons.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 19.06.2023.
//

import UIKit

enum Icons: String {
    // MARK: Detail Task Icons
    
    case lowImportance
    case highImportance
    
    // MARK: Task Cell Icons
    
    case statusDefault
    case statusHigh
    case statusLow
    case statusDone
    case calendar
}

// MARK: - Image render

extension Icons {
    
    /// Использует оригинальный цвет изображения
    var image: UIImage? {
        UIImage(named: self.rawValue)?.withRenderingMode(.alwaysOriginal)
    }
    
    /// Позволяет менять цвет изображения
    var imageTemplate: UIImage? {
        UIImage(named: self.rawValue)?.withRenderingMode(.alwaysTemplate)
    }
}
