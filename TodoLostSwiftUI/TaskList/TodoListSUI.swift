//
//  TodoListSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TodoListSUI: View {
    @State private var isPresented: Bool = false
    @State private var selectedItem: TodoListViewModelSUI?
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section(header: HStack {
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
                    ) {
                        ForEach(TodoListViewModelSUI.getModels(), id: \.id) { item in
                            Button {
                                selectedItem = item
                                isPresented = true
                            } label: {
                                TaskCellSUI(
                                    status: item.status,
                                    importance: item.importance,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    deadline: item.deadline
                                )
                            }
                            .padding([.top, .bottom], 16)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowBackground(Color(uiColor: Colors.backSecondary ?? UIColor.red))
                        }
                        
                        AddCellSUI()
                            .onTapGesture {
                                isPresented = true
                            }
                    }
                    .sheet(isPresented: $isPresented) {
                        TaskDetailSUI(task: selectedItem)
                            .onDisappear {
                                selectedItem = nil
                            }
                    }
                }
                .navigationTitle("Мои дела")
                .background(Color(uiColor: Colors.backPrimary ?? UIColor.red))
                .scrollContentBackground(.hidden)
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        isPresented = true
                    }, label: {
                        Image(uiImage: Icons.addPlusButton.image ?? UIImage())
                    })
                    .sheet(isPresented: $isPresented, content: {
                        TaskDetailSUI(task: nil)
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListSUI()
    }
}
