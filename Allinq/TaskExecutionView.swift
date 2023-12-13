//
//  TaskExecutionView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 20/11/2023.
//
//

import ARKit
import ConfettiView
import RealityKit
import SlideOverCard
import SwiftUI

struct TaskExecutionView: View {
    @State var taskDescription: String
    @State var taskAssignment: [[String]]

    var body: some View {
        TaskNavigationBar(taskDescription: taskDescription, taskAssignment: taskAssignment)
    }
}

struct TaskNavigationBar: View {
    @State var findObjectIndex: Int = 0
    @State var foundObject: Bool = false
    @State var taskDescription: String
    @State var taskAssignment: [[String]]
    @State private var currentObjectName: String? = ""
    @State private var counter: Int = 3
    @State var isCardPresented: Bool = false

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
                            self.currentObjectName = self.taskAssignment[self.findObjectIndex][0]
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
                                Label("Start over", systemImage: "arrow.triangle.2.circlepath")
                            }

                            Button(action: {
                                isCardPresented = true
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
                        Text("Looking for: " + (currentObjectName ?? "nil")).bold()
                        foundObject ? Label("", systemImage: "arkit").foregroundColor(.green) : Label("", systemImage: "arkit.badge.xmark").foregroundColor(.red)
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
                        isCardPresented = true

                    }) {
                        Text("Show details")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                    }.buttonStyle(.borderedProminent).tint(Color.blue
                        .opacity(0.95))
                }
            }
            .padding()
            .slideOverCard(isPresented: $isCardPresented) {
                ZStack {
                    VStack(alignment: .center, spacing: 25) {
                        Text(currentObjectName!).font(.system(size: 28, weight: .bold))

                        Text(taskAssignment[self.findObjectIndex][1]).font(.system(size: 18, weight: .medium)).multilineTextAlignment(.center)

                        Button("Done", action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if currentObjectName == "Complete!" {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                self.moveToNextObject()
                            }
                            isCardPresented = false
                        }).buttonStyle(SOCEmptyButton())

                    }.frame(height: 240)
                    if currentObjectName == "Complete!" {
                        ConfettiView().ignoresSafeArea()
                    }
                }
            }
        }
    }

    func moveToNextObject() {
        foundObject = false
        if findObjectIndex < taskAssignment.count - 1 {
            findObjectIndex += 1
            currentObjectName = taskAssignment[findObjectIndex][0]
            ARSessionManager.shared.startSession(findObjectName: $currentObjectName, foundObject: $foundObject)
        } else {
            foundObject = true
            isCardPresented = true
            currentObjectName = "Complete!"
        }
    }
}

struct ProgressBar: View {
    let findObjectNames: [[String]]
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
        if findObjectName != nil {}
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
    TaskExecutionView(taskDescription: "This is the task description", taskAssignment: [["Cable", "Unplug the cable from the switch"], ["Cable", "Plug-in new cable to the switch"], ["Cabinets", "Close the cabinet"]])
}
