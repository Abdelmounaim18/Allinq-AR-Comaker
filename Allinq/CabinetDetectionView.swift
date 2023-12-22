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

/// Initial view when selecting task, to validate user is at the right location.
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

/// ViewContainer containing the ARView.
/// - Parameters:
///  - findObjectName: Name of object to be found.
///  - foundObject: Boolean if object was found.
struct CabinetViewContainer: UIViewRepresentable {
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
