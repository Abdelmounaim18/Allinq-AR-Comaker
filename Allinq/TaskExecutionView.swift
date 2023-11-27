//
//  TaskExecutionView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 20/11/2023.
//
//

import ARKit
import RealityKit
import SwiftUI

struct TaskExecutionView: View {
    @State var taskDescription: String
    @State var taskAssignment: [String]

    var body: some View {
        TaskNavigationBar(taskDescription: taskDescription, taskAssignment: taskAssignment)
    }
}

struct TaskNavigationBar: View {
    @State var findObjectIndex: Int = 0
    @State var foundObject: Bool = false
    @State var taskDescription: String
    @State var taskAssignment: [String]
    @State private var currentObjectName: String? = ""

    @State var taskStarted: Bool = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    ARTaskExecutionView(findObjectName: $currentObjectName, foundObject: $foundObject)
                        .ignoresSafeArea()
                        .onAppear {
                            self.foundObject = false
                            self.currentObjectName = self.taskAssignment[self.findObjectIndex]
                            taskStarted = false
                        }
                        .onDisappear {
                            self.foundObject = false
                            ARSessionManager.shared.stopSession()
                        }.blur(radius: !taskStarted ? 25 : 0)

                    VStack {
                        Spacer()
                        Image(systemName: "livephoto.play")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                            .symbolEffect(
                                .pulse,
                                isActive: true
                            )
                            .padding(25)
                        Text(taskDescription)

                        Spacer()

                        Button(action: {
                            taskStarted = true
                            ARSessionManager.shared.startSession(findObjectName: self.$currentObjectName, foundObject: self.$foundObject)
                        }) {
                            Text("Start")
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                        }.buttonStyle(.borderedProminent).tint(Color.blue)
                    }.opacity(taskStarted ? 0 : 1)
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Task")
                            .font(.largeTitle.weight(.bold))

                        Spacer()

                        Menu {
                            Button(action: {
                                ARSessionManager.shared.startSession(findObjectName: self.$currentObjectName, foundObject: self.$foundObject)
                                self.foundObject = false
                                self.findObjectIndex = 0
                            }) {
                                Label("Restart session", systemImage: "arrow.triangle.2.circlepath")
                            }

                            Button(action: {
                                self.moveToNextObject()
                            }) {
                                Label("Skip step", systemImage: "arrow.right.circle")
                            }

                            Button(role: .destructive, action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Label("End task", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle").font(.system(size: 25)).foregroundColor(.white)
                        }
                    }
                    Text(taskDescription)

                    ProgressBar(findObjectNames: taskAssignment, progress: Double(findObjectIndex) / Double(taskAssignment.count))
                        .padding(.vertical, 8)

                    HStack {
                        Text("Find: " + (currentObjectName ?? "nil"))
                        Spacer()
                        Text("Found: " + foundObject.description)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .blur(radius: !taskStarted ? 25 : 0)
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
                    }.buttonStyle(.borderedProminent).tint(Color.blue
                        .opacity(0.95))
                }
            }
            .padding()
        }
    }

    private func moveToNextObject() {
        foundObject = false
        findObjectIndex += 1
        if findObjectIndex < taskAssignment.count {
            currentObjectName = taskAssignment[findObjectIndex]
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
    TaskExecutionView(taskDescription: "This is the task description", taskAssignment: ["Cabinets", "PowerSupply", "PowerConnector", "Cabinets"])
}
