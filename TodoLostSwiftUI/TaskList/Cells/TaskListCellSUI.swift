//
//  TaskListCellSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TaskCellSUI: View {
    let status: StatusTask
    let importance: Importance
    let title: String
    let subtitle: String?
    let deadline: Date?
    
    var body: some View {
        HStack(spacing: 12) {
            statusImage
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    if importance != .basic && status != .statusDone {
                        importanceImage?
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(uiColor: Colors.labelTertiary ?? UIColor.red))
                    }
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(
                            status == .statusDone
                            ? Color(uiColor: Colors.labelTertiary ?? UIColor.red)
                            : Color(uiColor: Colors.labelPrimary ?? UIColor.red)
                        )
                        .lineLimit(3)
                    
                        .strikethrough(status == .statusDone, color: Color(uiColor: Colors.labelTertiary ?? UIColor.red))
                }
                
                if deadline != nil {
                    HStack(spacing: 2) {
                        Image("calendar").renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(uiColor: Colors.labelTertiary ?? UIColor.red))
                        
                        Text(subtitle ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color(uiColor: Colors.labelTertiary ?? UIColor.red))
                    }
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button(action: {
                // Действие при свайпе влево
            }, label: {
                Image(uiImage: Icons.completion.image ?? UIImage())
            })
            .tint(Color(uiColor: Colors.green ?? UIColor.red))
        }
        .swipeActions(edge: .trailing) {
            Button(action: {
                // Действие при свайпе влево
            }, label: {
                Image(uiImage: Icons.trash.image ?? UIImage())
            })
            .tint(Color(uiColor: Colors.red ?? UIColor.red))
            
            Button(action: {
                // Действие при свайпе влево
            }, label: {
                Image(uiImage: Icons.info.image ?? UIImage())
            })
            .tint(Color(uiColor: Colors.grayLight ?? UIColor.red))
        }
        .contextMenu {
            Button(action: {
                // Логика выполнения задачи
            }, label: {
                Text("Выполнено")
                Image(uiImage: Icons.statusDone.image ?? UIImage())
            })
            
            Button(role: .destructive, action: {
                // Логика удаления задачи
            }, label: {
                Text("Удалить")
                Image(uiImage: Icons.trash.image?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    .foregroundColor(Color(uiColor: Colors.red ?? UIColor.red))
            })
        }
    }
    
    var statusImage: Image? {
        switch status {
        case .statusDefault:
            return Image(uiImage: Icons.statusDefault.image ?? UIImage())
        case .statusHigh:
            return Image(uiImage: Icons.statusHigh.image ?? UIImage())
        case .statusLow:
            return Image(uiImage: Icons.statusDefault.image ?? UIImage())
        case .statusDone:
            return Image(uiImage: Icons.statusDone.image ?? UIImage())
        }
    }
    
    var importanceImage: Image? {
        switch importance {
        case .low:
            return Image(uiImage: Icons.lowImportance.image ?? UIImage())
        case .basic:
            return nil
        case .important:
            return Image(uiImage: Icons.highImportance.image ?? UIImage())
        }
    }
}
