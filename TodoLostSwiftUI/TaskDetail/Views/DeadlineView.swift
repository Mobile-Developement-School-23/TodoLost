//
//  DeadlineView.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct DeadlineView: View {
    @Binding var isDeadline: Bool
    @Binding var isDatePickerVisible: Bool
    @Binding var selectedDate: Date
    var task: TodoListViewModelSUI?
    
    var body: some View {
        HStack {
            Toggle(isOn: $isDeadline) {
                Text("Сделать до")
                if isDeadline {
                    Button {
                        withAnimation {
                            isDatePickerVisible = true
                        }
                    } label: {
                        Text(selectedDate.toString())
                            .font(Font(Fonts.footnote))
                    }
                }
            }
            .onAppear {
                if task?.deadline != nil {
                    isDeadline = true
                } else {
                    isDeadline = false
                    isDatePickerVisible = false
                }
            }
            .onChange(of: isDeadline, perform: { newValue in
                withAnimation {
                    if !newValue {
                        isDatePickerVisible = false
                    }
                }
            })
            .padding(16)
            .animation(.easeOut(duration: 0.2), value: isDeadline)
        }
        .frame(height: 56)
    }
}
