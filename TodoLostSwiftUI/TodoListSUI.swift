//
//  TodoListSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TodoListSUI: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: HStack {
                    Text("Выполнено — 0")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .textCase(nil)
                    
                    Spacer()
                    
                    Button(action: {
                        // Действие при нажатии на кнопку в заголовке
                    }, label: {
                        Text("Показать")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .textCase(nil)
                    })
                }
                    .padding(.bottom, 12)
                ) {
                    TaskCellSUI(
                        status: .statusHigh,
                        importance: .important,
                        title: "Погладить кота",
                        subtitle: "14 июля"
                    )
                    .padding([.top, .bottom], 16)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    TaskCellSUI(
                        status: .statusDefault,
                        importance: .basic,
                        title: "Погладить кота",
                        subtitle: nil
                    )
                    .padding([.top, .bottom], 16)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    TaskCellSUI(
                        status: .statusDone,
                        importance: .basic,
                        title: "Погладить кота Погладить кота Погладить кота Погладить кота Погладить кота Погладить кота Погладить кота Погладить кота",
                        subtitle: "14 июля"
                    )
                    .padding([.top, .bottom], 16)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    TaskCellSUI(
                        status: .statusDone,
                        importance: .low,
                        title: "Погладить кота",
                        subtitle: "14 июля"
                    )
                    .padding([.top, .bottom], 16)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .navigationTitle("Мои дела")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListSUI()
    }
}

struct TaskCellSUI: View {
    let status: StatusTask
    let importance: Importance
    let title: String
    let subtitle: String?
    
    var body: some View {
        HStack(spacing: 12) {
            statusImage
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    if importance != .basic && status != .statusDone {
                        importanceImage?
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(status == .statusDone ? .secondary : .primary)
                        .lineLimit(3)
                        
                        .strikethrough(status == .statusDone, color: Color(uiColor: Colors.labelTertiary ?? UIColor.red))
                }
                
                if subtitle != nil && subtitle != "" {
                    HStack(spacing: 2) {
                        Image("calendar").renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                        
                        Text(subtitle ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .swipeActions(edge: .leading) {
            Button(action: {
                // Действие при свайпе влево
            }, label: {
                Image("completion")
            })
            .tint(.green)
        }
        .swipeActions(edge: .trailing) {
            
            Button(action: {
                // Действие при свайпе влево
            }, label: {
                Image("trash")
            })
            .tint(.red)
        }
        .contextMenu {
            Button(action: {
                // Логика выполнения задачи
            }, label: {
                Text("Выполнено")
                Image("statusDone")
            })
            
            Button(role: .destructive, action: {
                // Логика удаления задачи
            }, label: {
                Text("Удалить")
                Image("trash").renderingMode(.template)
                    .foregroundColor(Color.red)
            })
        }
    }
    
    var statusImage: Image? {
        switch status {
        case .statusDefault:
            return Image("statusDefault")
        case .statusHigh:
            return Image("statusHigh")
        case .statusLow:
            return Image("statusDefault")
        case .statusDone:
            return Image("statusDone")
        }
    }
    
    var importanceImage: Image? {
        switch importance {
        case .low:
            return Image("lowImportance")
        case .basic:
            return nil
        case .important:
            return Image("highImportance")
        }
    }
}
