//
//  TaskDetailSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TaskDetailSUI: View {
    let task: TodoListViewModelSUI?
    
    // TODO: () Вынести в отдельные константы по аналогии с UIKit
    private let placeholderColor = Color(uiColor: Colors.labelTertiary ?? UIColor.red)
    private let mainColor = Color(uiColor: Colors.labelPrimary ?? UIColor.red)
    
    @State var text: String
    @State private var selectedImportance = 0
    @State private var isDeadline = false
    @State private var selectedDate = Date().addingTimeInterval(86400)
    @State private var deadline: Date?
    @State private var isDatePickerVisible = false
    
    @State private var editorTextColor: Color
    @State private var isEditing = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(task: TodoListViewModelSUI?) {
        self.task = task
        
        _editorTextColor = State(
            initialValue: task == nil
            ? placeholderColor
            : mainColor
        )
        
        if let task {
            _text = State(initialValue: task.title)
            _selectedDate = State(initialValue: task.deadline ?? Date().addingTimeInterval(86400))
            _selectedImportance = State(initialValue: task.importance.index)
        } else {
            _text = State(initialValue: "Что надо сделать?")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TaskEditorView(
                        text: $text,
                        editorTextColor: $editorTextColor,
                        isEditing: $isEditing,
                        placeholderColor: placeholderColor,
                        mainColor: mainColor
                    )
                    
                    VStack(spacing: 0) {
                        ImportanceView(selectedImportance: $selectedImportance)
                        
                        Divider()
                            .padding([.leading, .trailing], 16)
                        
                        DeadlineView(
                            isDeadline: $isDeadline,
                            isDatePickerVisible: $isDatePickerVisible,
                            selectedDate: $selectedDate,
                            task: task
                        )
                        // Костыль для проверки скрытия клавиатуры
                        // ???: Как можно более грамотно скрыть клавиатуру
                        // чтобы не ломать работу Picker
                        .onTapGesture {
                            hideKeyboard()
                            isEditing = false
                            if text == "" {
                                text = "Что нужно сделать?"
                                editorTextColor = placeholderColor
                            }
                        }
                        
                        DeadlineDatePicker(
                            selectedDate: $selectedDate,
                            isDatePickerVisible: $isDatePickerVisible
                        )
                    }
                    .background(Color(uiColor: Colors.backSecondary ?? UIColor.red))
                    .cornerRadius(16)
                    
                    DeleteButton()
                }
            }
            .padding([.top, .leading, .trailing], 16)
            .background(Color(uiColor: Colors.backPrimary ?? UIColor.red))
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {}
                }
            }
        }
    }
}

struct TaskDetailSUI_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailSUI(task: nil)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
