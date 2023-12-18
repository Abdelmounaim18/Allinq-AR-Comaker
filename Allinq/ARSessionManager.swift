//
//  ARSessionManager.swift
//  Allinq
//
//  Created by Abdelmounaim Fathi on 19/11/2023.
//

import ARKit
import os.log
import RealityKit
import SwiftUI
import Vision

// MARK: - ARSession Manager

/// This class is responsible for starting and stopping the ARSession.
class ARSessionManager: NSObject, ARSessionDelegate {
    static let shared = ARSessionManager()
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ARSessionManager")

    var session: ARSession?
    var visionRequests = [VNRequest]()
    var timer: Timer?
    let arView = ARView(frame: .zero)
    var raycastResult: ARRaycastResult!
    var detectedObjectPosition: SIMD3<Float>?
    var addedBoxes = [AnchorEntity]()

    override private init() {
        super.init()
        arView.addCoaching()
        arView.session.delegate = self
    }

    // MARK: - Start Session

    /// This method starts the ARSession and the classification request.
    /// - Parameters:
    ///   - findObjectName: Name of object to be found.
    ///   - foundObject: Boolean if object was found.
    func startSession(findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
        stopSession()

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        session?.run(configuration)
        arView.session.run(configuration)
        startClassification(findObjectName: findObjectName, foundObject: foundObject)
        os_log("-- Session Started --")
    }

    // MARK: - Stop Session

    /// This method stops all procceses related to the ARSession and stops the classification request.
    func stopSession() {
        session?.pause()
        arView.session.pause()
        session = nil
        stopTimer()
        stopVision()
        removeAddedBoxes()
        os_log("-- Session Stopped --")
    }

    private func stopVision() {
        visionRequests.forEach { $0.cancel() }
        visionRequests.removeAll()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func removeAddedBoxes() {
        for boxEntity in addedBoxes {
            arView.scene.removeAnchor(boxEntity)
        }
        addedBoxes.removeAll()
    }

    // MARK: - Classification Timer

    /// The startClassification() sets a timer, responsible for sending the classification request every 3 seconds.

    private func startClassification(findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            if let raycastResult = self.performRaycasting() {
                self.detectedObjectPosition = SIMD3<Float>(raycastResult.worldTransform.columns.3.x,
                                                           raycastResult.worldTransform.columns.3.y,
                                                           raycastResult.worldTransform.columns.3.z)
                os_log("raycastResult: %@", log: self.log, type: .debug, raycastResult)
                visionRequest(findObjectName: findObjectName, foundObject: foundObject)
            }
            
        }
    }

    /// Adds box to scene at given position.
    /// - Parameter position: SIMD3 Position of box.
    private func addBox(at position: SIMD3<Float>) {
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        let sphereEntity = ModelEntity(mesh: sphereMesh)

        let material = SimpleMaterial(color: .systemBlue, isMetallic: false)
        sphereEntity.model?.materials = [material]

        let anchorEntity = AnchorEntity(world: position)
        anchorEntity.addChild(sphereEntity)

        arView.scene.addAnchor(anchorEntity)
        addedBoxes.append(anchorEntity)
    }

    // MARK: - Raycasting

    /// This method performs a raycast from the center of the screen.
    /// - Returns: ARRaycastResult
    private func performRaycasting() -> ARRaycastResult? {
        guard arView.session.currentFrame != nil else { return nil }

        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)

        if let result = results.first {
            return result
        }

        return nil
    }

    // MARK: - Vision Classification Request

    /// This method creates a classification request using the Vision framework. It is responsible for detecting the object in the camera feed.
    /// - Parameters:
    ///   - findObjectName: name of object to be found.
    ///   - foundObject: boolean if object was found.
    private func visionRequest(findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
        guard let currentFrame = arView.session.currentFrame else { return }
        var boxPlaced = false
        let buffer = currentFrame.capturedImage
        let visionModel = try! VNCoreMLModel(for: AllinqImageClassifier().model)
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard error == nil, let observations = request.results,
                  let observation = observations.first as? VNClassificationObservation
            else {
                return
            }

            #if DEBUG
            os_log("findObjectName: %@, foundObject: %d, detectedObject: %@ (%.0f%)", log: self.log, type: .debug, findObjectName.wrappedValue ?? "nil", foundObject.wrappedValue, observation.identifier, observation.confidence * 100)
            #endif

            DispatchQueue.main.async {
                if observation.identifier.lowercased() == findObjectName.wrappedValue?.lowercased() && !foundObject.wrappedValue {
                    if let raycastResult = self.performRaycasting() {
                        self.detectedObjectPosition = SIMD3<Float>(raycastResult.worldTransform.columns.3.x,
                                                                   raycastResult.worldTransform.columns.3.y,
                                                                   raycastResult.worldTransform.columns.3.z)
                    }

                    if let position = self.detectedObjectPosition {
                        self.addBox(at: position)
                        boxPlaced = true
                    }

                    if boxPlaced {
                        self.stopTimer()
                        self.stopVision()
                        findObjectName.wrappedValue = observation.identifier
                        foundObject.wrappedValue = true
                    }

                    #if DEBUG
                    os_log("findObjectName: %@, foundObject: %d, ###FOUND###: %@ (%.0f%)", log: self.log, type: .debug, findObjectName.wrappedValue ?? "nil", foundObject.wrappedValue, observation.identifier, observation.confidence * 100)
                    #endif
                }
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        visionRequests = [request]
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
                                                        orientation: .upMirrored,
                                                        options: [:])

        DispatchQueue.main.async {
            try! imageRequestHandler.perform(self.visionRequests)
        }
    }
}

// MARK: - ARCoachingOverlayViewDelegate

extension ARView: ARCoachingOverlayViewDelegate {
    /// Adds coaching overlay to ARView.
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        #if !targetEnvironment(simulator)
        coachingOverlay.session = session
        #endif
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(coachingOverlay)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("did deactivate")
    }
}
