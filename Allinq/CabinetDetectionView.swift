//
//  ARDefaultView.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 16/11/2023.
//

import ARKit
import RealityKit
import SwiftUI

// MARK: - CabinetDetectionView

struct CabinetDetectionView: View {
    @Binding var findObjectName: String?
    @Binding var foundObject: Bool

    var body: some View {
        CabinetViewContainer(findObjectName: $findObjectName, foundObject: $foundObject)
            .ignoresSafeArea()
            .onAppear {
                self.foundObject = false
                ARSessionManager.shared.startSession(findObjectName: $findObjectName, foundObject: $foundObject)
            }
            .onDisappear {
                self.foundObject = false
                ARSessionManager.shared.stopSession()
            }
    }
}

// MARK: - CabinetViewContainer

struct CabinetViewContainer: UIViewRepresentable {
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
        var parent: CabinetViewContainer
        @Binding var findObjectName: String?
        @Binding private var foundObject: Bool

        init(_ parent: CabinetViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
            self.parent = parent
            self._findObjectName = findObjectName
            self._foundObject = foundObject
        }
    }
}
