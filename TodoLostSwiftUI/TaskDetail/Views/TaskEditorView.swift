//
//  TaskEditorView.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct TaskEditorView: View {
    @Binding var text: String
    @Binding var editorTextColor: Color
    @Binding var isEditing: Bool
    var placeholderColor: Color
    var mainColor: Color
    
    var body: some View {
        TextEditor(text: $text)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 5, trailing: 16))
            .font(Font(Fonts.body))
            .foregroundColor(editorTextColor)
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
    }
}
