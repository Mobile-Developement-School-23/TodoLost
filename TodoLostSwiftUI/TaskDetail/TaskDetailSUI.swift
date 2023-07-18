//
//  TaskDetailSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TaskDetailSUI: View {
    let task: TodoListViewModelSUI?
    
    @State var text: String
    @State private var selectedOption = 0
    @State private var isDeadline = false
    @State private var selectedDate = Date().addingTimeInterval(86400)
    @State private var deadline: Date?
    @State private var isDatePickerVisible = false
    
    // ???: Как работает эта штука? почему теперь свойство вызывается как функция чтобы сработало закрытие экрана?
    // решение честно стырено с интернета без понимания что за магия тут написана
    @Environment(\.dismiss) private var dismiss
    
    init(task: TodoListViewModelSUI?) {
        self.task = task
        
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
                        .foregroundColor(
                            task == nil
                            ? Color(uiColor: Colors.labelTertiary ?? UIColor.red)
                            : Color(uiColor: Colors.labelPrimary ?? UIColor.red)
                        )
                    // ???: Как это говно работает? Почему чтобы кнопки появились их нужно добавить сюда?
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
                                        // TODO: Работает с каким то багом
                                        // после того как состояние устанавливается в true,
                                        // не сбрасывается в false при переключении свитча
                                        //                                        isDatePickerVisible = true
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
                            .padding(16)
                            .animation(.easeOut(duration: 0.2), value: isDeadline)
                        }
                        .frame(height: 56)
                        
                        if isDatePickerVisible || isDeadline {
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
