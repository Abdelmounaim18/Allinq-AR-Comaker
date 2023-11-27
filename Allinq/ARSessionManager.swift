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

class ARSessionManager: NSObject, ARSessionDelegate {
    static let shared = ARSessionManager()
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ARSessionManager")

    var session: ARSession?
    var visionRequests = [VNRequest]()
    var timer: Timer?
    let arView = ARView(frame: .zero)

    override private init() {
        super.init()

        arView.session.delegate = self
    }

    // MARK: - Start Session

    func startSession(findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
        stopSession()
        session?.run(ARWorldTrackingConfiguration())
        arView.session.run(ARWorldTrackingConfiguration())
        startClassification(findObjectName: findObjectName, foundObject: foundObject)
        os_log("-- Session Started --")
    }

    // MARK: - Stop Session

    func stopSession() {
        session?.pause()
        arView.session.pause()
        session = nil
        stopTimer()
        stopVision()
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

    private func startClassification(findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
        arView.addCoaching()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [self] _ in
            visionRequest(findObjectName: findObjectName, foundObject: foundObject)
        }
    }

    // MARK: - Vision Classification Request

    private func visionRequest(findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
        guard let currentFrame = arView.session.currentFrame else { return }

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
//                    self.stopSession()
                    self.stopTimer()
                    self.stopVision()
                    findObjectName.wrappedValue = observation.identifier
                    foundObject.wrappedValue = true

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

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        #if !targetEnvironment(simulator)
        coachingOverlay.session = session
        #endif
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(coachingOverlay)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("did deactivate")
    }
}
