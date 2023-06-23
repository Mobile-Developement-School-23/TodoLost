//
//  Icons.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 19.06.2023.
//

import UIKit

enum Icons: String {
    case lowImportance
    case highImportance
}

extension Icons {
    var image: UIImage? {
        UIImage(named: self.rawValue)?.withRenderingMode(.alwaysOriginal)
    }
}
