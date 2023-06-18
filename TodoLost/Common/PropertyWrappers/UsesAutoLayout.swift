//
//  UsesAutoLayout.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.06.2023.
//

import UIKit

@propertyWrapper
public struct UsesAutoLayout<T: UIView> {
    public var wrappedValue: T {
        didSet {
            setTranslatesAutoresizingMaskIntoConstraints()
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        setTranslatesAutoresizingMaskIntoConstraints()
    }
    
    private func setTranslatesAutoresizingMaskIntoConstraints() {
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
}
