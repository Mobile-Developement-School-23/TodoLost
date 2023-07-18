//
//  TaskDetailSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TaskDetailSUI: View {
    let task: TodoListViewModelSUI?
    
    // TODO: Вынести в отдельные константы по аналогии с UIKit
    private let placeholderColor = Color(uiColor: Colors.labelTertiary ?? UIColor.red)
    private let mainColor = Color(uiColor: Colors.labelPrimary ?? UIColor.red)
    
    @State var text: String
    @State private var selectedOption = 0
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
        } else {
            _text = State(initialValue: "Что надо сделать?")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TextEditor(text: $text)
                        .padding(EdgeInsets(top: 12, leading: 16,bottom: 5 ,trailing: 16))
                        .font(Font(Fonts.body))
                        .foregroundColor(editorTextColor)
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
                        .background(Color(uiColor: Colors.backSecondary ?? UIColor.red))
                        .onTapGesture {
                            isEditing = true
                        }
                        .onChange(of: isEditing) { newValue in
                            if newValue {
                                if editorTextColor == placeholderColor {
                                    editorTextColor = mainColor
                                    text = ""
                                }
                            }
                        }
                        .frame(height: 120)
                        .cornerRadius(16)
                        .scrollContentBackground(.hidden)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Важность")
                            
                            Spacer()
                            
                            Picker("", selection: $selectedOption) {
                                Image(uiImage: Icons.lowImportance.image ?? UIImage())
                                    .tag(0)
                                Text("нет")
                                    .tag(1)
                                Image(uiImage: Icons.highImportance.image ?? UIImage())
                                    .tag(2)
                            }
                            .frame(maxWidth: 150)
                            .pickerStyle(.segmented)
                            
                        }
                        .padding([.top, .bottom], 10)
                        .padding([.leading, .trailing], 16)
                        .frame(height: 56)
                        
                        Divider()
                            .padding([.leading, .trailing], 16)
                        
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
                        
                        if isDatePickerVisible {
                            Divider()
                                .padding([.leading, .trailing], 16)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding(.top, 8)
                                .padding([.leading, .trailing], 16)
                                .padding(.bottom, 12)
                                .onChange(of: selectedDate) { newDate in
                                    selectedDate = newDate
                                }
                                .animation(.easeOut(duration: 0.2), value: isDatePickerVisible)
                        }
                    }
                    .background(Color(uiColor: Colors.backSecondary ?? UIColor.red))
                    .cornerRadius(16)
                    
                    Button {} label: {
                        Text("Удалить")
                            .tint(Color(uiColor: Colors.red ?? UIColor.black))
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .background(Color(uiColor: Colors.backSecondary ?? UIColor.red))
                    .cornerRadius(16)
                }
            }
            .padding([.top, .leading, .trailing], 16)
            .background(Color(uiColor: Colors.backPrimary ?? UIColor.red))
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TaskDetauilSUI_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailSUI(task: nil)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
