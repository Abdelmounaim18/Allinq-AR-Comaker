//
//  TaskExecutionView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 20/11/2023.
//
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
    @State var findObjectIndex: Int = 0
    @State var foundObject: Bool = false
    @State private var currentObjectName: String? = ""
    @Environment(\.presentationMode) var presentationMode
    let findObjectNames = ["Cabinets", "PowerSupply", "Cable", "PowerConnector", "PowerModule"]

    var body: some View {
        ZStack {
            NavigationStack {
                ARTaskExecutionView(findObjectName: $currentObjectName, foundObject: $foundObject)
                    .ignoresSafeArea()
                    .onAppear {
                        self.foundObject = false
                        self.currentObjectName = self.findObjectNames[self.findObjectIndex]
                        ARSessionManager.shared.startSession(findObjectName: self.$currentObjectName, foundObject: self.$foundObject)
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
                            ARSessionManager.shared.startSession(findObjectName: self.$currentObjectName, foundObject: self.$foundObject)
                            self.foundObject = false
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 25)).foregroundColor(.blue)
                        }
                        Button(action: {
                            self.moveToNextObject()
                        }) {
                            Image(systemName: "arrow.right.circle").font(.system(size: 25)).foregroundColor(.green)
                        }
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle").font(.system(size: 25)).foregroundColor(.red)
                        }
                    }

                    ProgressBar(findObjectNames: findObjectNames, progress: Double(findObjectIndex) / Double(findObjectNames.count))
                        .padding(.vertical, 8)

                    HStack {
                        Text("Find: " + (currentObjectName ?? "nil"))
                        Spacer()
                        Text("Found: " + foundObject.description)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationBarHidden(true)
            .tint(.white)

            VStack {
                Spacer()
                if foundObject {
                    Button(action: {
                        self.moveToNextObject()
                    }) {
                        Text("Next Step")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent).tint(.green)
                }
            }
            .padding()
        }
    }

    private func moveToNextObject() {
        foundObject = false
        findObjectIndex += 1
        if findObjectIndex < findObjectNames.count {
            currentObjectName = findObjectNames[findObjectIndex]
            ARSessionManager.shared.startSession(findObjectName: $currentObjectName, foundObject: $foundObject)
        } else {
            currentObjectName = "END OF LIST"
            print("Einde van de lijst bereikt")
        }
    }
}

struct ProgressBar: View {
    let findObjectNames: [String]
    let progress: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(0 ..< findObjectNames.count), id: \.self) { blockIndex in
                RoundedRectangle(cornerRadius: 4)
                    .fill(blockIndex < Int(progress * Double(findObjectNames.count)) ? Color.green : Color.gray)
                    .frame(height: 8)
            }
        }
    }
}

struct ARTaskExecutionView: UIViewRepresentable {
    @Binding var findObjectName: String?
    @Binding var foundObject: Bool

    func makeUIView(context: Context) -> ARView {
        return ARSessionManager.shared.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if findObjectName != nil {
            // Do something with the current object name
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

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    TaskExecutionView()
}
