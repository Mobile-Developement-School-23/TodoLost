//
//  ContentView.swift
//  TodoLostSwiftUI
//
//  Created by Дмитрий Данилин on 15.07.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Hello, world!")
                Text("Hello, world!")
                Text("Hello, world!")
                Text("Hello, world!")
            }
            .navigationTitle("Мои дела")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
