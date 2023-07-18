//
//  ImportanceView.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct ImportanceView: View {
    @Binding var selectedImportance: Int
    var task: TodoListViewModelSUI?
    
    var body: some View {
        HStack {
            Text("Важность")
            
            Spacer()
            
            Picker("", selection: $selectedImportance) {
                Image(uiImage: Icons.lowImportance.image ?? UIImage())
                    .tag(0)
                Text("нет")
                    .tag(1)
                Image(uiImage: Icons.highImportance.image ?? UIImage())
                    .tag(2)
            }
            .frame(maxWidth: 150)
            .pickerStyle(.segmented)
            .onAppear {
                if let task {
                    selectedImportance = task.importance.index
                }
            }
            
        }
        .padding([.top, .bottom], 10)
        .padding([.leading, .trailing], 16)
        .frame(height: 56)
    }
}
