//
//  TaskExecutionView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 20/11/2023.
//

import RealityKit
import SwiftUI

struct TaskExecutionView: View {
    var body: some View {
        ZStack {
            TaskNavigationBar()
        }
    }
}

struct TaskNavigationBar: View {
    @State var findObjectName: String? = "Cable"
    @State var foundObject: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ARTaskExecutionView(findObjectName: $findObjectName, foundObject: $foundObject)
                .ignoresSafeArea()
                .onAppear {
                    ARSessionManager.shared.stopSession()
                    self.foundObject = false
                    ARSessionManager.shared.startSession(findObjectName: $findObjectName, foundObject: $foundObject)
                }
                .onDisappear {
                    self.foundObject = false
                    ARSessionManager.shared.stopSession()
                }
        }
        .safeAreaInset(edge: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Task")
                        .font(.largeTitle.weight(.bold))
                    Spacer()
                    Button(action: {
                        ARSessionManager.shared.startSession(findObjectName: $findObjectName, foundObject: $foundObject)
                        self.foundObject = false
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 25)).foregroundColor(.blue)
                    }
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle").font(.system(size: 25)).foregroundColor(.red)
                    }
                }
                Text("Find: " + (findObjectName?.description ?? "nil"))
                Text("Found: " + foundObject.description)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationBarHidden(true)
        .tint(.white)
    }
}

struct ARTaskExecutionView: UIViewRepresentable {
    @Binding var findObjectName: String?
    @Binding var foundObject: Bool

    func makeUIView(context: Context) -> ARView {
        ARSessionManager.shared.startSession(findObjectName: $findObjectName, foundObject: $foundObject)

        return ARSessionManager.shared.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if findObjectName != nil {
            ARSessionManager.shared.stopSession()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        var parent: ARTaskExecutionView
        @Binding var findObjectName: String?
        @Binding private var foundObject: Bool

        init(_ parent: ARTaskExecutionView, findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
            self.parent = parent
            self._findObjectName = findObjectName
            self._foundObject = foundObject
        }
    }
}

#Preview {
    TaskExecutionView()
}
