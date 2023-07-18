//
//  DeadlineDatePicker.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 18.07.2023.
//

import SwiftUI

struct DeadlineDatePicker: View {
    @Binding var selectedDate: Date
    @Binding var isDatePickerVisible: Bool
    
    var body: some View {
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
}
