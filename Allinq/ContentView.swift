//
//  ContentView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 14/11/2023.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image("Background")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(.ultraThinMaterial)

                ScrollView {
                    VStack(spacing: 16) {
                        HomeCard()
                        TasksCard()
                        SettingsCard()
                    }
                    .padding(5)
                }
                .navigationBarTitle("Allinq AR")
            }
        }
    }
}

struct HomeCard: View {
    var body: some View {
        NavigationLink(destination: TaskExecutionView()) {
            CardView(label: "Home", systemImage: "house")
        }
    }
}

struct TasksCard: View {
    var body: some View {
        NavigationLink(destination: TasksView()) {
            CardView(label: "Tasks", systemImage: "square.stack.3d.up")
        }
    }
}

struct SettingsCard: View {
    var body: some View {
        NavigationLink(destination: SettingsView()) {
            CardView(label: "Settings", systemImage: "gear")
        }
    }
}

struct CardView: View {
    var label: String
    var systemImage: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    Color.white
                        .opacity(0.2)
                )
                .frame(height: 120)

            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                VStack(alignment: .leading) {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .padding()
        }
        .frame(height: 120)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
