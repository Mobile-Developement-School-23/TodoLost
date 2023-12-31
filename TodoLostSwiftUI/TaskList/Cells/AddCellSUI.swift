//
//  AddCellSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct AddCellSUI: View {
    @Binding var isPressed: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                isPressed = true
            } label: {
                Text("Новое")
                    .foregroundColor(.secondary)
            }
        }
        .padding([.top, .bottom], 16)
        .listRowInsets(EdgeInsets(top: 0, leading: 52, bottom: 0, trailing: 16))
        .listRowBackground(Color(uiColor: Colors.backSecondary ?? UIColor.red))
    }
}
