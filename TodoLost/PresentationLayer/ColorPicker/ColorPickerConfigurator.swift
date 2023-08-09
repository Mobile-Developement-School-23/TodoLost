//
//  ColorPickerConfigurator.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 23.06.2023.
//

import UIKit

/// Конфигурация MVP модуля
final class ColorPickerConfigurator {
    func config(
        view: UIViewController,
        completion: ((String) -> Void)?
    ) {
        guard let view = view as? ColorPickerViewController else { return }
        let presenter = ColorPickerPresenter(view: view)
        
        view.presenter = presenter
        view.completion = completion
        presenter.view = view
    }
}
