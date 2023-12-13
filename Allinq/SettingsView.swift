//
//  SettingsView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 14/11/2023.
//

import SwiftUI

/// SettingsView
struct SettingsView: View {
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .overlay(.ultraThinMaterial)

            VStack {
                ScrollView {}
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
