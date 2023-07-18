//
//  AddBottomButton.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct AddBottomButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
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
