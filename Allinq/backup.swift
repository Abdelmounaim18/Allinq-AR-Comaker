////
////  ARDefaultView.swift
////  Allinq
////
////  Created by Abdelmounaim Fathi on 16/11/2023.
////
////
////
////import SwiftUI
////import RealityKit
////import ARKit
////import Vision
////
////struct ARDefaultView: View {
////    @Binding var findObjectName: String?
////    @Binding var foundObject: Bool
////
////    var body: some View {
////        ARViewContainer(findObjectName: $findObjectName,foundObject: $foundObject)
////            .ignoresSafeArea()
////            .onAppear() {
////                DispatchQueue.main.async {
////                    ARSessionManager.shared.stopSession()
////                    self.foundObject = false
////#if DEBUG
////                    print(String("###view has appeared###, foundObject set to: "), foundObject)
////
////#endif
////
////
////                }
////            }
////            .onDisappear {
////
////                DispatchQueue.main.async {
////                    ARSessionManager.shared.stopSession()
////                    self.foundObject = false
////#if DEBUG
////                    print(String("###view has disappeard###, foundObject set to: "), foundObject)
////
////#endif
////
////
////                }
////
////
////            }
////    }
////}
////
////
////class ARSessionManager {
////    static let shared = ARSessionManager()
////
////    var session: ARSession?
////    var visionRequests = [VNRequest]()
////    var timer: Timer?
////
////
////    private init() {}
////
////    func startSession() {
////        // Code om de AR-sessie te starten
////        session = ARSession()
////        // ... andere initialisatiecode ...
////        session?.run(ARWorldTrackingConfiguration())
////    }
////
////    func stopSession() {
////        // Code om de AR-sessie te stoppen
////        session?.pause()
////        session = nil
////
////        stopTimer()
////        stopVision()
////
////    }
////
////    func stopVision() {
////        visionRequests.forEach { $0.cancel() }
////        visionRequests.removeAll()
////    }
////
////
////
////    func stopTimer() {
////        timer?.invalidate()
////        timer = nil
////    }
////}
////
////
////struct ARViewContainer: UIViewRepresentable {
////    @Binding var findObjectName: String?
////    @Binding var foundObject: Bool
////
////    let imageClassifierModel: AllinqImageClassifier = {
////        do {
////            let configuration = MLModelConfiguration()
////            return try AllinqImageClassifier(configuration: configuration)
////        } catch let error {
////            fatalError(error.localizedDescription)
////        }
////    }()
////
////    let arView = ARView(frame: .zero)
////    var rayCastResultValue: ARRaycastResult!
////    var visionRequests = [VNRequest]()
////    var timer: Timer?
////
////    func makeUIView(context: Context) -> ARView {
////        // Direct starten met classificeren
////        context.coordinator.startClassification()
////        ARSessionManager.shared.startSession()
////        return arView
////    }
////
////    func updateUIView(_ uiView: ARView, context: Context) {
////        if findObjectName != nil {
////            ARSessionManager.shared.stopSession()
////        }
////    }
////
////    func makeCoordinator() -> Coordinator {
////        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
////    }
////
////    final class Coordinator: NSObject {
////        var parent: ARViewContainer
////        @Binding var findObjectName: String?
////        @Binding private var foundObject: Bool
////
////        init(_ parent: ARViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool> ) {
////            self.parent = parent
////            self._findObjectName = findObjectName
////            self._foundObject = foundObject
////        }
////
////        func startClassification() {
////            parent.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
////                self.visionRequest()
////            }
////        }
////
////        func visionRequest() {
////            guard let currentFrame = parent.arView.session.currentFrame else {
////                return
////            }
////
////            let buffer = currentFrame.capturedImage
////            let visionModel = try! VNCoreMLModel(for: parent.imageClassifierModel.model)
////            let request = VNCoreMLRequest(model: visionModel) { request, error in
////                if error != nil {
////                    return
////                }
////                guard let observations = request.results,
////                      let observation = observations.first as? VNClassificationObservation else {
////                    return
////                }
////
////#if DEBUG
////
////                print(self.foundObject)
////                print(String(format: "Object gedetecteerd: \(observation.identifier) (🔎%.0f", observation.confidence * 100) + "%)")
////#endif
////
////                DispatchQueue.main.async {
////                    if observation.identifier.lowercased() == self.findObjectName?.lowercased() && self.foundObject == false {
////                        self.stopTimer()
////                        ARSessionManager.shared.stopSession()
////                        self.findObjectName = observation.identifier
////                        self.foundObject = true
////
////#if DEBUG
////                        print(self.foundObject)
////                        print(String(format: "###FOUND###: \(observation.identifier) ###", self.foundObject) + "###")
////#endif
////                    }
////                }
////
////            }
////            request.imageCropAndScaleOption = .centerCrop
////            parent.visionRequests = [request]
////            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
////                                                            orientation: .upMirrored,
////                                                            options: [:])
////
////            DispatchQueue.main.async {
////                try! imageRequestHandler.perform(self.parent.visionRequests)
////            }
////        }
////
////        //        func stopVision() {
////        //            parent.visionRequests.forEach { $0.cancel() }
////        //            parent.visionRequests.removeAll()
////        //        }
////        //
////        //
////        //        // Stop de timer wanneer deze niet meer nodig is
////        func stopTimer() {
////            parent.timer?.invalidate()
////            parent.timer = nil
////        }
////
////
////    }
////}
//
////import SwiftUI
////import RealityKit
////import ARKit
////import Vision
////
////struct ARDefaultView: View {
////    @Binding var findObjectName: String?
////    @Binding var foundObject: Bool
////
////    var body: some View {
////        ARViewContainer(findObjectName: $findObjectName, foundObject: $foundObject)
////            .ignoresSafeArea()
////            .onAppear {
////                ARSessionManager.shared.startSession()
////                self.foundObject = false
////            }
////            .onDisappear {
////                ARSessionManager.shared.stopSession()
////                self.foundObject = false
////            }
////    }
////}
////
////class ARSessionManager {
////    static let shared = ARSessionManager()
////
////    private var session: ARSession?
////    private var visionRequests = [VNRequest]()
////    private var timer: Timer?
////
////    private init() {}
////
////    func startSession() {
////        stopSession()
////        session = ARSession()
////        session?.run(ARWorldTrackingConfiguration())
////    }
////
////    func stopSession() {
////        session?.pause()
////        session = nil
////        stopTimer()
////        stopVision()
////    }
////
////    private func stopVision() {
////        visionRequests.forEach { $0.cancel() }
////        visionRequests.removeAll()
////    }
////
////    private func stopTimer() {
////        timer?.invalidate()
////        timer = nil
////    }
////}
////
////struct ARViewContainer: UIViewRepresentable {
////    @Binding var findObjectName: String?
////    @Binding var foundObject: Bool
////
////    private let imageClassifierModel: AllinqImageClassifier = {
////        do {
////            let configuration = MLModelConfiguration()
////            return try AllinqImageClassifier(configuration: configuration)
////        } catch let error {
////            fatalError(error.localizedDescription)
////        }
////    }()
////
////    private let arView = ARView(frame: .zero)
////
////    func makeUIView(context: Context) -> ARView {
////        context.coordinator.startClassification()
////        return arView
////    }
////
////    func updateUIView(_ uiView: ARView, context: Context) {
////        if findObjectName != nil {
////            ARSessionManager.shared.stopSession()
////        }
////    }
////
////    func makeCoordinator() -> Coordinator {
////        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
////    }
////
////    final class Coordinator: NSObject {
////        var parent: ARViewContainer
////        @Binding var findObjectName: String?
////        @Binding private var foundObject: Bool
////        var timer: Timer?
////        var visionRequests = [VNRequest]()
////
////        init(_ parent: ARViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool> ) {
////            self.parent = parent
////            self._findObjectName = findObjectName
////            self._foundObject = foundObject
////        }
////
////        func startClassification() {
////            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
////                self.visionRequest()
////            }
////        }
////
////        private func visionRequest() {
////            guard let currentFrame = parent.arView.session.currentFrame else { return }
////
////            let buffer = currentFrame.capturedImage
////            let visionModel = try! VNCoreMLModel(for: parent.imageClassifierModel.model)
////            let request = VNCoreMLRequest(model: visionModel) { request, error in
////                guard error == nil, let observations = request.results,
////                      let observation = observations.first as? VNClassificationObservation else {
////                    return
////                }
////
////                #if DEBUG
////                print(self.foundObject)
////                print(String(format: "Object gedetecteerd: \(observation.identifier) (🔎%.0f", observation.confidence * 100) + "%)")
////                #endif
////
////                DispatchQueue.main.async {
////                    if observation.identifier.lowercased() == self.findObjectName?.lowercased() && !self.foundObject {
////                        ARSessionManager.shared.stopSession()
////                        self.findObjectName = observation.identifier
////                        self.foundObject = true
////
////                        #if DEBUG
////                        print(self.foundObject)
////                        print(String(format: "###FOUND###: \(observation.identifier) ###", self.foundObject) + "###")
////                        #endif
////                    }
////                }
////            }
////            request.imageCropAndScaleOption = .centerCrop
////            visionRequests = [request]
////            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
////                                                            orientation: .upMirrored,
////                                                            options: [:])
////
////            DispatchQueue.main.async {
////                try! imageRequestHandler.perform(self.visionRequests)
////            }
////        }
////
////        private func stopTimer() {
////            timer?.invalidate()
////            timer = nil
////        }
////    }
////}
////
////import SwiftUI
////import RealityKit
////import ARKit
////import Vision
////
////struct ARDefaultView: View {
////    @ObservedObject var sharedData: SharedData
////
////    var body: some View {
////        ARViewContainer(sharedData: sharedData)
////                    .ignoresSafeArea()
////                    .onAppear {
////                        ARSessionManager.shared.startSession()
////                        self.sharedData.foundObject = false
////                    }
////                    .onDisappear {
////                        ARSessionManager.shared.stopSession()
////                        self.sharedData.foundObject = false
////                    }
////    }
////}
////
////class ARSessionManager: NSObject, ARSessionDelegate {
////    static let shared = ARSessionManager()
////
////    var arView: ARView!
////    var visionRequests = [VNRequest]()
////    var timer: Timer?
////    @ObservedObject var sharedData = SharedData()
////
////    private override init() {
////        super.init()
////        arView = ARView(frame: .zero)
////        arView.session.delegate = self
////    }
////
////    func startSession() {
////        stopSession()
////        arView.session.run(ARWorldTrackingConfiguration())
////        startClassification()
////    }
////
////    func stopSession() {
////        arView.session.pause()
////        stopTimer()
////        stopVision()
////    }
////
////    private func stopVision() {
////        visionRequests.forEach { $0.cancel() }
////        visionRequests.removeAll()
////    }
////
////    private func stopTimer() {
////        timer?.invalidate()
////        timer = nil
////    }
////
////    private func startClassification() {
////        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
////            self.visionRequest()
////        }
////    }
////
////    private func visionRequest() {
////        guard let currentFrame = arView.session.currentFrame else { return }
////
////        let buffer = currentFrame.capturedImage
////        let visionModel = try! VNCoreMLModel(for: AllinqImageClassifier().model)
////        let request = VNCoreMLRequest(model: visionModel) { request, error in
////            guard error == nil, let observations = request.results,
////                  let observation = observations.first as? VNClassificationObservation else {
////                return
////            }
////
////            #if DEBUG
////            print(self.sharedData.findObjectName)
////            print(self.sharedData.foundObject)
////            print(String(format: "Object gedetecteerd: \(observation.identifier) (🔎%.0f", observation.confidence * 100) + "%)")
////            #endif
////
////            DispatchQueue.main.async {
////                if observation.identifier.lowercased() == self.sharedData.findObjectName?.lowercased() && !self.sharedData.foundObject {
////                                self.stopSession()
////                                self.sharedData.findObjectName = observation.identifier
////                                self.sharedData.foundObject = true
////
////
////                    #if DEBUG
////                    print(self.sharedData.foundObject)
////                    print(String(format: "###FOUND###: \(observation.identifier) ###", self.sharedData.foundObject) + "###")
////                    #endif
////                }
////            }
////        }
////        request.imageCropAndScaleOption = .centerCrop
////        visionRequests = [request]
////        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
////                                                        orientation: .upMirrored,
////                                                        options: [:])
////
////        DispatchQueue.main.async {
////            try! imageRequestHandler.perform(self.visionRequests)
////        }
////    }
////}
////
////struct ARViewContainer: UIViewRepresentable {
////    @ObservedObject var sharedData: SharedData
////
////    func makeUIView(context: Context) -> ARView {
////        ARSessionManager.shared.startSession()
////        ARSessionManager.shared.sharedData = sharedData
////        return ARSessionManager.shared.arView
////    }
////
////    func updateUIView(_ uiView: ARView, context: Context) {
////        if findObjectName != nil {
////            ARSessionManager.shared.stopSession()
////        }
////    }
////
////    func makeCoordinator() -> Coordinator {
////        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
////    }
////
////    final class Coordinator: NSObject {
////        var parent: ARViewContainer
////        @Binding var findObjectName: String?
////        @Binding private var foundObject: Bool
////
////        init(_ parent: ARViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
////            self.parent = parent
////            self._findObjectName = findObjectName
////            self._foundObject = foundObject
////        }
////    }
////}
////
////struct ARDefaultView_Previews: PreviewProvider {
////    static var previews: some View {
////        ARDefaultView(findObjectName: .constant(nil), foundObject: .constant(false))
////    }
////}
////
//
// import SwiftUI
// import RealityKit
// import ARKit
//
// struct ARDefaultView: View {
//    @ObservedObject var sharedData: SharedData
//
//    var body: some View {
//        ARViewContainer(sharedData: sharedData)
//            .ignoresSafeArea()
//            .onAppear {
//                self.sharedData.foundObject = false
//            }
//            .onDisappear {
//                self.sharedData.foundObject = false
//            }
//    }
// }
//
// struct ARViewContainer: UIViewRepresentable {
//    @ObservedObject var sharedData: SharedData
//
//    func makeUIView(context: Context) -> ARView {
//        ARSessionManager.shared.startSession()
//        ARSessionManager.shared.sharedData = sharedData
//        return ARSessionManager.shared.arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        if sharedData.findObjectName != nil {
//            ARSessionManager.shared.stopSession()
//        }
//    }
// }

// MARK: - Old ARsession manager

// class ARSessionManager: NSObject, ARSessionDelegate {
//    static let shared = ARSessionManager()
//    @Binding var findObjectName: String?
//    @Binding var foundObject: Bool
//
//    var arView: ARView!
//    var visionRequests = [VNRequest]()
//    var timer: Timer?
//
//    private override init() {
//        super.init()
//        arView = ARView(frame: .zero)
//        arView.session.delegate = self
//    }
//
//    func startSession() {
//        let configuration = ARWorldTrackingConfiguration()
//        arView.session.run(configuration)
//        startClassification()
//    }
//
//    func stopSession() {
//        arView.session.pause()
//        stopTimer()
//        stopVision()
//    }
//
//    private func stopVision() {
//        visionRequests.forEach { $0.cancel() }
//        visionRequests.removeAll()
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    private func startClassification() {
//        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//            print("Timer fired")
//            self.visionRequest()
//        }
//    }
//
//    private func visionRequest() {
//        print("Vision request started")
//        guard let currentFrame = arView.session.currentFrame else { return }
//
//        let buffer = currentFrame.capturedImage
//        let visionModel = try! VNCoreMLModel(for: AllinqImageClassifier().model)
//        let request = VNCoreMLRequest(model: visionModel) { request, error in
//            guard error == nil, let observations = request.results,
//                  let observation = observations.first as? VNClassificationObservation else {
//                return
//            }
//
//            print(observation.identifier.lowercased())
//
//            DispatchQueue.main.async {
//                if observation.identifier.lowercased() == self.findObjectName?.lowercased() && !self.foundObject {
//                    self.stopSession()
//                    self.findObjectName = observation.identifier
//                    self.foundObject = true
//                }
//            }
//        }
//        request.imageCropAndScaleOption = .centerCrop
//        visionRequests = [request]
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
//                                                        orientation: .upMirrored,
//                                                        options: [:])
//
//        DispatchQueue.main.async {
//            try! imageRequestHandler.perform(self.visionRequests)
//        }
//        print("Vision request completed")
//    }
// }

// MARK: - Old ARDefaultview

//
//
// import SwiftUI
// import RealityKit
// import ARKit
// import Vision
//
// struct ARDefaultView: View {
//    @Binding var findObjectName: String?
//    @Binding var foundObject: Bool
//
//    var body: some View {
//        ARViewContainer(findObjectName: $findObjectName,foundObject: $foundObject)
//            .ignoresSafeArea()
//            .onAppear() {
//                DispatchQueue.main.async {
//                    ARSessionManager.shared.stopSession()
//                    self.foundObject = false
// #if DEBUG
//                    print(String("###view has appeared###, foundObject set to: "), foundObject)
//
// #endif
//
//
//                }
//            }
//            .onDisappear {
//
//                DispatchQueue.main.async {
//                    ARSessionManager.shared.stopSession()
//                    self.foundObject = false
// #if DEBUG
//                    print(String("###view has disappeard###, foundObject set to: "), foundObject)
//
// #endif
//
//
//                }
//
//
//            }
//    }
// }
//
//
// class ARSessionManager {
//    static let shared = ARSessionManager()
//
//    var session: ARSession?
//    var visionRequests = [VNRequest]()
//    var timer: Timer?
//
//
//    private init() {}
//
//    func startSession() {
//        // Code om de AR-sessie te starten
//        session = ARSession()
//        // ... andere initialisatiecode ...
//        session?.run(ARWorldTrackingConfiguration())
//    }
//
//    func stopSession() {
//        // Code om de AR-sessie te stoppen
//        session?.pause()
//        session = nil
//
//        stopTimer()
//        stopVision()
//
//    }
//
//    func stopVision() {
//        visionRequests.forEach { $0.cancel() }
//        visionRequests.removeAll()
//    }
//
//
//
//    func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
// }
//
//
// struct ARViewContainer: UIViewRepresentable {
//    @Binding var findObjectName: String?
//    @Binding var foundObject: Bool
//
//    let imageClassifierModel: AllinqImageClassifier = {
//        do {
//            let configuration = MLModelConfiguration()
//            return try AllinqImageClassifier(configuration: configuration)
//        } catch let error {
//            fatalError(error.localizedDescription)
//        }
//    }()
//
//    let arView = ARView(frame: .zero)
//    var rayCastResultValue: ARRaycastResult!
//    var visionRequests = [VNRequest]()
//    var timer: Timer?
//
//    func makeUIView(context: Context) -> ARView {
//        // Direct starten met classificeren
//        context.coordinator.startClassification()
//        ARSessionManager.shared.startSession()
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        if findObjectName != nil {
//            ARSessionManager.shared.stopSession()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
//    }
//
//    final class Coordinator: NSObject {
//        var parent: ARViewContainer
//        @Binding var findObjectName: String?
//        @Binding private var foundObject: Bool
//
//        init(_ parent: ARViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool> ) {
//            self.parent = parent
//            self._findObjectName = findObjectName
//            self._foundObject = foundObject
//        }
//
//        func startClassification() {
//            parent.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                self.visionRequest()
//            }
//        }
//
//        func visionRequest() {
//            guard let currentFrame = parent.arView.session.currentFrame else {
//                return
//            }
//
//            let buffer = currentFrame.capturedImage
//            let visionModel = try! VNCoreMLModel(for: parent.imageClassifierModel.model)
//            let request = VNCoreMLRequest(model: visionModel) { request, error in
//                if error != nil {
//                    return
//                }
//                guard let observations = request.results,
//                      let observation = observations.first as? VNClassificationObservation else {
//                    return
//                }
//
// #if DEBUG
//
//                print(self.foundObject)
//                print(String(format: "Object gedetecteerd: \(observation.identifier) (🔎%.0f", observation.confidence * 100) + "%)")
// #endif
//
//                DispatchQueue.main.async {
//                    if observation.identifier.lowercased() == self.findObjectName?.lowercased() && self.foundObject == false {
//                        self.stopTimer()
//                        ARSessionManager.shared.stopSession()
//                        self.findObjectName = observation.identifier
//                        self.foundObject = true
//
// #if DEBUG
//                        print(self.foundObject)
//                        print(String(format: "###FOUND###: \(observation.identifier) ###", self.foundObject) + "###")
// #endif
//                    }
//                }
//
//            }
//            request.imageCropAndScaleOption = .centerCrop
//            parent.visionRequests = [request]
//            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
//                                                            orientation: .upMirrored,
//                                                            options: [:])
//
//            DispatchQueue.main.async {
//                try! imageRequestHandler.perform(self.parent.visionRequests)
//            }
//        }
//
//        //        func stopVision() {
//        //            parent.visionRequests.forEach { $0.cancel() }
//        //            parent.visionRequests.removeAll()
//        //        }
//        //
//        //
//        //        // Stop de timer wanneer deze niet meer nodig is
//        func stopTimer() {
//            parent.timer?.invalidate()
//            parent.timer = nil
//        }
//
//
//    }
// }

// MARK: - 19-11-2023 21:31 working version, but vision stays active bug

// import SwiftUI
// import RealityKit
// import ARKit
// import Vision
//
// struct ARDefaultView: View {
//    @Binding var findObjectName: String?
//    @Binding var foundObject: Bool
//
//    var body: some View {
//        ARViewContainer(findObjectName: $findObjectName, foundObject: $foundObject)
//            .ignoresSafeArea()
//            .onAppear {
//                ARSessionManager.shared.startSession()
//                self.foundObject = false
//            }
//            .onDisappear {
//                ARSessionManager.shared.stopSession()
//                self.foundObject = false
//            }
//    }
// }

// class ARSessionManager {
//    static let shared = ARSessionManager()
//
//    private var session: ARSession?
//    private var visionRequests = [VNRequest]()
//    private var timer: Timer?
//
//    private init() {}
//
//    func startSession() {
//        stopSession()
//        session = ARSession()
//        session?.run(ARWorldTrackingConfiguration())
//    }
//
//    func stopSession() {
//        session?.pause()
//        session = nil
//        stopTimer()
//        stopVision()
//    }
//
//    private func stopVision() {
//        visionRequests.forEach { $0.cancel() }
//        visionRequests.removeAll()
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
// }
//
// struct ARViewContainer: UIViewRepresentable {
//    @Binding var findObjectName: String?
//    @Binding var foundObject: Bool
//
//    private let imageClassifierModel: AllinqImageClassifier = {
//        do {
//            let configuration = MLModelConfiguration()
//            return try AllinqImageClassifier(configuration: configuration)
//        } catch let error {
//            fatalError(error.localizedDescription)
//        }
//    }()
//
//    private let arView = ARView(frame: .zero)
//
//    func makeUIView(context: Context) -> ARView {
//        context.coordinator.startClassification()
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        if findObjectName != nil {
//            ARSessionManager.shared.stopSession()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
//    }
//
//    final class Coordinator: NSObject {
//        var parent: ARViewContainer
//        @Binding var findObjectName: String?
//        @Binding private var foundObject: Bool
//        var timer: Timer?
//        var visionRequests = [VNRequest]()
//
//        init(_ parent: ARViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool> ) {
//            self.parent = parent
//            self._findObjectName = findObjectName
//            self._foundObject = foundObject
//        }
//
//        func startClassification() {
//            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                self.visionRequest()
//            }
//        }
//
//        private func visionRequest() {
//            guard let currentFrame = parent.arView.session.currentFrame else { return }
//
//            let buffer = currentFrame.capturedImage
//            let visionModel = try! VNCoreMLModel(for: parent.imageClassifierModel.model)
//            let request = VNCoreMLRequest(model: visionModel) { request, error in
//                guard error == nil, let observations = request.results,
//                      let observation = observations.first as? VNClassificationObservation else {
//                    return
//                }
//
//                #if DEBUG
//                print(self.foundObject)
//                print(String(format: "Object gedetecteerd: \(observation.identifier) (🔎%.0f", observation.confidence * 100) + "%)")
//                #endif
//
//                DispatchQueue.main.async {
//                    if observation.identifier.lowercased() == self.findObjectName?.lowercased() && !self.foundObject {
//                        ARSessionManager.shared.stopSession()
//                        self.findObjectName = observation.identifier
//                        self.foundObject = true
//
//                        #if DEBUG
//                        print(self.foundObject)
//                        print(String(format: "###FOUND###: \(observation.identifier) ###", self.foundObject) + "###")
//                        #endif
//                    }
//                }
//            }
//            request.imageCropAndScaleOption = .centerCrop
//            visionRequests = [request]
//            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
//                                                            orientation: .upMirrored,
//                                                            options: [:])
//
//            DispatchQueue.main.async {
//                try! imageRequestHandler.perform(self.visionRequests)
//            }
//        }
//
//        private func stopTimer() {
//            timer?.invalidate()
//            timer = nil
//        }
//    }
// }

// import SwiftUI
// import RealityKit
// import ARKit
// import Vision
//
// struct ARDefaultView: View {
//    @ObservedObject var sharedData: SharedData
//
//    var body: some View {
//        ARViewContainer(sharedData: sharedData)
//                    .ignoresSafeArea()
//                    .onAppear {
//                        ARSessionManager.shared.startSession()
//                        self.sharedData.foundObject = false
//                    }
//                    .onDisappear {
//                        ARSessionManager.shared.stopSession()
//                        self.sharedData.foundObject = false
//                    }
//    }
// }
//
// class ARSessionManager: NSObject, ARSessionDelegate {
//    static let shared = ARSessionManager()
//
//    var arView: ARView!
//    var visionRequests = [VNRequest]()
//    var timer: Timer?
//    @ObservedObject var sharedData = SharedData()
//
//    private override init() {
//        super.init()
//        arView = ARView(frame: .zero)
//        arView.session.delegate = self
//    }
//
//    func startSession() {
//        stopSession()
//        arView.session.run(ARWorldTrackingConfiguration())
//        startClassification()
//    }
//
//    func stopSession() {
//        arView.session.pause()
//        stopTimer()
//        stopVision()
//    }
//
//    private func stopVision() {
//        visionRequests.forEach { $0.cancel() }
//        visionRequests.removeAll()
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    private func startClassification() {
//        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//            self.visionRequest()
//        }
//    }
//
//    private func visionRequest() {
//        guard let currentFrame = arView.session.currentFrame else { return }
//
//        let buffer = currentFrame.capturedImage
//        let visionModel = try! VNCoreMLModel(for: AllinqImageClassifier().model)
//        let request = VNCoreMLRequest(model: visionModel) { request, error in
//            guard error == nil, let observations = request.results,
//                  let observation = observations.first as? VNClassificationObservation else {
//                return
//            }
//
//            #if DEBUG
//            print(self.sharedData.findObjectName)
//            print(self.sharedData.foundObject)
//            print(String(format: "Object gedetecteerd: \(observation.identifier) (🔎%.0f", observation.confidence * 100) + "%)")
//            #endif
//
//            DispatchQueue.main.async {
//                if observation.identifier.lowercased() == self.sharedData.findObjectName?.lowercased() && !self.sharedData.foundObject {
//                                self.stopSession()
//                                self.sharedData.findObjectName = observation.identifier
//                                self.sharedData.foundObject = true
//
//
//                    #if DEBUG
//                    print(self.sharedData.foundObject)
//                    print(String(format: "###FOUND###: \(observation.identifier) ###", self.sharedData.foundObject) + "###")
//                    #endif
//                }
//            }
//        }
//        request.imageCropAndScaleOption = .centerCrop
//        visionRequests = [request]
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
//                                                        orientation: .upMirrored,
//                                                        options: [:])
//
//        DispatchQueue.main.async {
//            try! imageRequestHandler.perform(self.visionRequests)
//        }
//    }
// }
//
// struct ARViewContainer: UIViewRepresentable {
//    @ObservedObject var sharedData: SharedData
//
//    func makeUIView(context: Context) -> ARView {
//        ARSessionManager.shared.startSession()
//        ARSessionManager.shared.sharedData = sharedData
//        return ARSessionManager.shared.arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        if findObjectName != nil {
//            ARSessionManager.shared.stopSession()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self, findObjectName: $findObjectName, foundObject: $foundObject)
//    }
//
//    final class Coordinator: NSObject {
//        var parent: ARViewContainer
//        @Binding var findObjectName: String?
//        @Binding private var foundObject: Bool
//
//        init(_ parent: ARViewContainer, findObjectName: Binding<String?>, foundObject: Binding<Bool>) {
//            self.parent = parent
//            self._findObjectName = findObjectName
//            self._foundObject = foundObject
//        }
//    }
// }
//
// struct ARDefaultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARDefaultView(findObjectName: .constant(nil), foundObject: .constant(false))
//    }
// }
//
