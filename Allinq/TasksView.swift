//
//  TasksView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 14/11/2023.
//

import SlideOverCard
import SwiftUI

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
    var description: String
    var imageName: String
}

// MARK: - TaskView + Task Items

struct TasksView: View {
    @State private var screenWidth = UIScreen.main.bounds.width
    @State private var selectedTask: Task? = nil
    @State private var isCardPresented: Bool = false
    
    func impactFeedback(style: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(style)
    }
    
    var tasks: [Task] = [
        Task(
            title: "Cable Swap",
            icon: "cable.coaxial",
            description: "Replacing A FibreOptic Cable",
            imageName: "cableSwap"
        ),
        Task(
            title: "Patch Panel",
            icon: "xserve",
            description: "Installation of Patch Panel",
            imageName: "patchPanelInstall"
        ),
        Task(
            title: "Fibre Switch",
            icon: "server.rack",
            description: "Adding Fibre Switch",
            imageName: "fibreSwitch"
        ),
        Task(
            title: "Cabinet",
            icon: "power.circle",
            description: "Turn Off Cabinet For Maintenance",
            imageName: "psuRack"
        ),
        Task(
            title: "Power Strip",
            icon: "poweroutlet.strip",
            description: "Connect Module to Power Grid",
            imageName: "powerStrip"
        ),
    ]
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .overlay(.ultraThinMaterial)
            
            ScrollView {
                VStack {
                    ForEach(tasks) { task in
                        TaskCard(task: task)
                            .onTapGesture {
                                selectedTask = task
                                isCardPresented = true
                            }
                    }
                }
                .padding(5)
            }
            .navigationTitle("Tasks")
        }.slideOverCard(isPresented: $isCardPresented, onDismiss: {
            selectedTask = nil
        }) {
            if let selectedTask = selectedTask {
                TaskDetailView(isCardPresented: $isCardPresented, task: selectedTask)
                    .onDisappear {
                        isCardPresented = false
                    }
            }
        }
    }
}

// MARK: - Task Card

struct TaskCard: View {
    var task: Task
    
    @State private var isCardPresented: Bool = false
    
    var body: some View {
        ZStack {
            Image(task.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    Color.black
                        .opacity(0.5)
                )
                .frame(height: 120)
            
            HStack {
                Image(systemName: task.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(task.description)
                        .font(.subheadline)
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

// MARK: - Card SlideOver

struct TaskDetailView: View {
    @State private var isNavigationActive: Bool = false
    @Binding var isCardPresented: Bool
    @State private var findObjectName: String? = "Cabinets"
    @State private var foundObject: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var task: Task
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            VStack {
                Text("Task").font(.system(size: 28, weight: .bold))
                Text(task.description)
            }
            
            ZStack {
                CabinetDetectionView(findObjectName: $findObjectName, foundObject: $foundObject)
                    .blur(radius: foundObject ? 25 : 0)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white, lineWidth: 2)
                    )
                VStack {
                    if foundObject {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.green)
                            .symbolEffect(
                                .pulse,
                                isActive: true
                            )
                            .padding(10)
                            .onAppear {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                        
                    } else {
                        Image(systemName: "text.viewfinder")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .symbolEffect(
                                .pulse,
                                isActive: true
                            )
                            .padding(10)
                    }
                    Text(foundObject ? "Found!" : "Looking for cabinet").font(.callout)
                }
            }
            
            VStack {
                NavigationLink(destination: TaskExecutionView()) {
                    Button("Start", action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        self.isCardPresented = false
                    })
                }.buttonStyle(SOCActionButton()).disabled(!foundObject)
//                Button("Start", action: {
//                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                    self.isCardPresented = false
                ////                    presentationMode.wrappedValue.dismiss()
//                    isNavigationActive = true
//
//                }).buttonStyle(SOCActionButton()).disabled(!foundObject)
                
                Button("Cancel", action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    self.isCardPresented = false
                }).buttonStyle(SOCEmptyButton())
            }
        }.frame(height: 480)
    }
}

struct TasksViewPreviews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
