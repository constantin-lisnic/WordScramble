//
//  ContentView.swift
//  WordScramble
//
//  Created by Constantin Lisnic on 13/11/2024.
//

import Inject
import SwiftUI

struct ContentView: View {
    @ObserveInjection var inject

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("this damn")
        }
        .padding()
        .enableInjection()
    }
}

#Preview {
    ContentView()
}
