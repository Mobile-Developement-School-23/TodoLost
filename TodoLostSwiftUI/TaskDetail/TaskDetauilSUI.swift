//
//  TaskDetauilSUI.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct TaskDetauilSUI: View {
    let item: TodoListViewModelSUI?
    
    var body: some View {
        Text(item?.id ?? "")
    }
}

struct TaskDetauilSUI_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetauilSUI(item: nil)
    }
}
