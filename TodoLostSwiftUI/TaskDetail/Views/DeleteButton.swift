//
//  DeleteButton.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct DeleteButton: View {
    var body: some View {
        Button {
            print("Delete button pressed")
        } label: {
            Text("Удалить")
                .tint(Color(uiColor: Colors.red ?? UIColor.black))
                .frame(maxWidth: .infinity, minHeight: 56)
        }
        .background(Color(uiColor: Colors.backSecondary ?? UIColor.red))
        .cornerRadius(16)
    }
}
