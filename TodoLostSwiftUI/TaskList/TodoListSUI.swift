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
                    Section(header: SectionHeaderView()) {
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
                        
                        AddCellSUI(isPressed: $isPresented)
                    }
                }
                .navigationTitle("Мои дела")
                .background(Color(uiColor: Colors.backPrimary ?? UIColor.red))
                .scrollContentBackground(.hidden)
                .sheet(isPresented: $isPresented) {
                    TaskDetailSUI(task: selectedItem)
                        .onDisappear {
                            selectedItem = nil
                        }
                }
                
                AddBottomButton(isPresented: $isPresented)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListSUI()
    }
}
