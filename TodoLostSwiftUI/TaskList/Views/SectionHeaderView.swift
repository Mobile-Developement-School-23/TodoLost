//
//  SectionHeaderView.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct SectionHeaderView: View {
    var body: some View {
        HStack {
            Text("Выполнено — 0")
                .font(.body)
                .foregroundColor(Color(uiColor: Colors.labelTertiary ?? UIColor.red))
                .textCase(nil)
            
            Spacer()
            
            Button(action: {
                // Действие при нажатии на кнопку в заголовке
            }, label: {
                Text("Показать")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: Colors.blue ?? UIColor.red))
                    .textCase(nil)
            })
        }
            .listRowInsets(EdgeInsets(top: 18, leading: 16, bottom: 12, trailing: 16))
    }
}
