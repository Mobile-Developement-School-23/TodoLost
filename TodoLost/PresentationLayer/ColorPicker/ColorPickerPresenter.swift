//
//  ColorPickerPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 23.06.2023.
//

import Foundation

/// Протокол взаимодействия ViewController-a с презенетром
protocol ColorPickerPresentationLogic: AnyObject {
    init(view: ColorPickerView)
}

final class ColorPickerPresenter {
    // MARK: - Public Properties
    
    weak var view: ColorPickerView?
    
    // MARK: - Private properties
    
    // MARK: - Initializer
    
    required init(view: ColorPickerView) {
        self.view = view
    }
}

// MARK: - Presentation Logic

extension ColorPickerPresenter: ColorPickerPresentationLogic {
    
}
