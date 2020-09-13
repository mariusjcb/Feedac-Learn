//
//  RecoderView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 12.09.2020.
//

//import UIKit
//import AVFoundation
//import Photos
//
//class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
//
//    var assetWriter: AVAssetWriter?
//    var writer: AVAssetWriterInput?
//    private let chunkMaxDuration = 10.0
//    private var chunkStartTime: CMTime! = nil
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
////        recordingQueue.async {
////            self.write(sampleBuffer, ofType: AVMediaType.video.rawValue)
////        }
//
//        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//
//        let currentChunkDuration = CMTimeGetSeconds(CMTimeSubtract(presentationTimeStamp, chunkStartTime))
//        if currentChunkDuration >= chunkMaxDuration {
//            let chunkAssetWriter = assetWriter!
//            let assetWriterInput = self.writer
//            assetWriterInput?.markAsFinished()
//            chunkAssetWriter.endSession(atSourceTime: presentationTimeStamp)
//            chunkAssetWriter.finishWriting {
//                self.mergeVideos(urls: self.getTempVideos(), excludedUrl: self.chunkOutputURL!, completion: { exportSession in
//                    if let exportSession = exportSession {
//                        PHPhotoLibrary.shared().performChanges({
//                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportSession.outputURL!)
//                        }) { saved, error in
//                            DispatchQueue.main.async {
//                                if saved {
//                                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
//                                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                                    alertController.addAction(defaultAction)
//                                    self.present(alertController, animated: true, completion: nil)
//                                }
//                            }
//                        }
//                    }
//                })
//                }
//            }
//        }
//    }
//
//    func write(_ sampleBuffer: CMSampleBuffer?, ofType mediaType: String?) {
//        var presentationTime: CMTime? = nil
//        if let sampleBuffer = sampleBuffer {
//            presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//        }
//
//        if assetWriter == nil {
//            self.assetWriter = try! AVAssetWriter(outputURL: URL(fileURLWithPath: (NSTemporaryDirectory() as NSString)
//                                                                    .appendingPathComponent(((UUID().uuidString) as NSString)
//                                                                                                .appendingPathExtension("saved.ts")!)),
//                                                 fileType: .mov)
//            self.assetWriter?.shouldOptimizeForNetworkUse = true
//            self.writer = AVAssetWriterInput(mediaType: .video, outputSettings: nil, sourceFormatHint: CMSampleBufferGetFormatDescription(sampleBuffer!))
//        }
//
//        if assetWriter?.status == .unknown {
//            self.assetWriter?.add(writer!)
//            if assetWriter!.startWriting() {
//                if let presentationTime = presentationTime {
//                    assetWriter!.startSession(atSourceTime: presentationTime)
//                }
//            } else {
//                print("Error writing initial buffer")
//            }
//        }
//
//        if assetWriter?.status == .writing {
//            if mediaType == AVMediaType.video.rawValue {
//                if let sampleBuffer = sampleBuffer {
//                    writer!.append(sampleBuffer)
//                    assetWriter?.finishWriting { }
//                    assetWriter = nil
//                }
//            }
//        }
//    }
//
//    private var movieChunkNumber = 0
//    private var chunkDuration = CMTime.zero
//    public var fileUrl: URL?
//    private var spinner: UIActivityIndicatorView!
//
//    var windowOrientation: UIInterfaceOrientation {
//        return view.window?.windowScene?.interfaceOrientation ?? .unknown
//    }
//
//    override var shouldAutorotate: Bool {
//        if let movieFileOutput = movieFileOutput {
//            return !movieFileOutput.isRecording
//        }
//        return true
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .all
//    }
//
//    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:))))
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
//        videoPreviewLayer?.backgroundColor = UIColor.red.cgColor
//        videoPreviewLayer!.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(videoPreviewLayer!)
//
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            break
//
//        case .notDetermined:
//            sessionQueue.suspend()
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
//                if !granted {
//                    self.setupResult = .notAuthorized
//                }
//                self.sessionQueue.resume()
//            })
//
//        default: setupResult = .notAuthorized
//        }
//
//        sessionQueue.async {
//            self.configureSession()
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        videoPreviewLayer?.frame = view.bounds
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        sessionQueue.async {
//            switch self.setupResult {
//            case .success:
//                self.addObservers()
//                self.isSessionRunning = self.session.isRunning
//                let movieFileOutput = AVCaptureMovieFileOutput()
//
//                self.session.beginConfiguration()
//                self.session.sessionPreset = .hd1920x1080
//                if self.session.canAddOutput(self.outputData) {
//                    self.session.addOutput(self.outputData)
//                }
//                self.session.commitConfiguration()
//                self.outputData.setSampleBufferDelegate(self, queue: DispatchQueue.main)
//                self.session.startRunning()
//            case .notAuthorized:
//                DispatchQueue.main.async {
//                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
//                    let message = NSLocalizedString(changePrivacySetting,
//                                                    comment: "Alert message when the user has denied access to the camera")
//                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
//
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//                                                            style: .cancel,
//                                                            handler: nil))
//
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
//                                                            style: .`default`,
//                                                            handler: { _ in
//                                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
//                                                                                          options: [:],
//                                                                                          completionHandler: nil)
//                    }))
//
//                    self.present(alertController, animated: true, completion: nil)
//                }
//
//            case .configurationFailed:
//                DispatchQueue.main.async {
//                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
//                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
//                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
//
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//                                                            style: .cancel,
//                                                            handler: nil))
//
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        sessionQueue.async {
//            if self.setupResult == .success {
//                self.session.stopRunning()
//                self.isSessionRunning = self.session.isRunning
//                self.removeObservers()
//            }
//        }
//
//        super.viewWillDisappear(animated)
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        videoPreviewLayer?.frame = view.frame
//        if let videoPreviewLayerConnection = videoPreviewLayer?.connection {
//            let deviceOrientation = UIDevice.current.orientation
//            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
//                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
//                    return
//            }
//
//            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
//        }
//    }
//
//    // MARK: Session Management
//    private func startRecordingChunkFile() {
//        let filename = String(format: "capture-%.2i.mov", movieChunkNumber)
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
//        movieFileOutput!.startRecording(to: url, recordingDelegate: self)
//
//        movieChunkNumber += 1
//    }
//
//    private enum SessionSetupResult {
//        case success
//        case notAuthorized
//        case configurationFailed
//    }
//
//    private let session = AVCaptureSession()
//    private var isSessionRunning = false
//    private var selectedSemanticSegmentationMatteTypes = [AVSemanticSegmentationMatte.MatteType]()
//    private let sessionQueue = DispatchQueue(label: "session queue")
//    private let recordingQueue = DispatchQueue(label: "recording queue")
//    private var setupResult: SessionSetupResult = .success
//    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
//
//    private func configureSession() {
//        if setupResult != .success {
//            return
//        }
//
//        session.beginConfiguration()
//        session.sessionPreset = .photo
//
//        do {
//            var defaultVideoDevice: AVCaptureDevice?
//            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
//                defaultVideoDevice = dualCameraDevice
//            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//                defaultVideoDevice = backCameraDevice
//            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
//                defaultVideoDevice = frontCameraDevice
//            }
//            guard let videoDevice = defaultVideoDevice else {
//                print("Default video device is unavailable.")
//                setupResult = .configurationFailed
//                session.commitConfiguration()
//                return
//            }
//            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//
//            if session.canAddInput(videoDeviceInput) {
//                session.addInput(videoDeviceInput)
//                self.videoDeviceInput = videoDeviceInput
//
//                DispatchQueue.main.async {
//                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
//                    if self.windowOrientation != .unknown {
//                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
//                            initialVideoOrientation = videoOrientation
//                        }
//                    }
//
//                    self.videoPreviewLayer?.connection?.videoOrientation = initialVideoOrientation
//                }
//            } else {
//                print("Couldn't add video device input to the session.")
//                setupResult = .configurationFailed
//                session.commitConfiguration()
//                return
//            }
//        } catch {
//            print("Couldn't create video device input: \(error)")
//            setupResult = .configurationFailed
//            session.commitConfiguration()
//            return
//        }
//
//        do {
//            let audioDevice = AVCaptureDevice.default(for: .audio)
//            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
//
//            if session.canAddInput(audioDeviceInput) {
//                session.addInput(audioDeviceInput)
//            } else {
//                print("Could not add audio device input to the session")
//            }
//        } catch {
//            print("Could not create audio device input: \(error)")
//        }
//
//        session.commitConfiguration()
//    }
//
//    func resumeInterruptedSession() {
//        sessionQueue.async {
//            self.session.startRunning()
//            self.isSessionRunning = self.session.isRunning
//            if !self.session.isRunning {
//                DispatchQueue.main.async {
//                    let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
//                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
//                    alertController.addAction(cancelAction)
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            } else {
//            }
//        }
//    }
//
//    // MARK: Device Configuration
//
//    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
//                                                                               mediaType: .video, position: .unspecified)
//
//    /// - Tag: ChangeCamera
//    public func changeCamera() {
//        sessionQueue.async {
//            let currentVideoDevice = self.videoDeviceInput.device
//            let currentPosition = currentVideoDevice.position
//
//            let preferredPosition: AVCaptureDevice.Position
//            let preferredDeviceType: AVCaptureDevice.DeviceType
//
//            switch currentPosition {
//            case .unspecified, .front:
//                preferredPosition = .back
//                preferredDeviceType = .builtInDualCamera
//
//            case .back:
//                preferredPosition = .front
//                preferredDeviceType = .builtInTrueDepthCamera
//
//            @unknown default:
//                print("Unknown capture position. Defaulting to back, dual-camera.")
//                preferredPosition = .back
//                preferredDeviceType = .builtInDualCamera
//            }
//            let devices = self.videoDeviceDiscoverySession.devices
//            var newVideoDevice: AVCaptureDevice? = nil
//
//            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
//                newVideoDevice = device
//            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
//                newVideoDevice = device
//            }
//
//            if let videoDevice = newVideoDevice {
//                do {
//                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//                    self.session.beginConfiguration()
//                    self.session.removeInput(self.videoDeviceInput)
//
//                    if self.session.canAddInput(videoDeviceInput) {
//                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
//                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
//
//                        self.session.addInput(videoDeviceInput)
//                        self.videoDeviceInput = videoDeviceInput
//                    } else {
//                        self.session.addInput(self.videoDeviceInput)
//                    }
//                    if let connection = self.movieFileOutput?.connection(with: .video) {
//                        if connection.isVideoStabilizationSupported {
//                            connection.preferredVideoStabilizationMode = .auto
//                        }
//                    }
//                    self.session.commitConfiguration()
//                } catch {
//                    print("Error occurred while creating video device input: \(error)")
//                }
//            }
//        }
//    }
//
//    @objc private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
//        guard let devicePoint = videoPreviewLayer?.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view)) else { return }
//        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
//    }
//
//    private func focus(with focusMode: AVCaptureDevice.FocusMode,
//                       exposureMode: AVCaptureDevice.ExposureMode,
//                       at devicePoint: CGPoint,
//                       monitorSubjectAreaChange: Bool) {
//
//        sessionQueue.async {
//            let device = self.videoDeviceInput.device
//            do {
//                try device.lockForConfiguration()
//
//                /*
//                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
//                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
//                 */
//                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
//                    device.focusPointOfInterest = devicePoint
//                    device.focusMode = focusMode
//                }
//
//                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
//                    device.exposurePointOfInterest = devicePoint
//                    device.exposureMode = exposureMode
//                }
//
//                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
//                device.unlockForConfiguration()
//            } catch {
//                print("Could not lock device for configuration: \(error)")
//            }
//        }
//    }
//
//    // MARK: Recording Movies
//
//    private var movieFileOutput: AVCaptureMovieFileOutput?
//    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
//    private let outputData = AVCaptureVideoDataOutput()
//
//    public func setRecording(_ enabled: Bool) {
//        guard let movieFileOutput = self.movieFileOutput else {
//            return
//        }
//
//        startRecordingChunkFile()
////        if !movieFileOutput.isRecording {
////            let videoPreviewLayerOrientation = videoPreviewLayer?.connection?.videoOrientation
////            sessionQueue.async {
////                if UIDevice.current.isMultitaskingSupported {
////                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
////                }
////
////                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
////                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
////
////                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
////
////                if availableVideoCodecTypes.contains(.hevc) {
////                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
////                }
////
////                let outputFileName = NSUUID().uuidString
////                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(((outputFileName + "-1") as NSString).appendingPathExtension("ts")!)
////                self.fileUrl = URL(fileURLWithPath: outputFilePath)
////                movieFileOutput.startRecording(to: self.fileUrl!, recordingDelegate: self)
////                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////                    let outputFilePath2 = (NSTemporaryDirectory() as NSString).appendingPathComponent(((outputFileName + "-2") as NSString).appendingPathExtension("ts")!)
////                    self.fileUrl = URL(fileURLWithPath: outputFilePath2)
////                    movieFileOutput.stopRecording()
////                    movieFileOutput.startRecording(to: self.fileUrl!, recordingDelegate: self)
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////                        let outputFilePath3 = (NSTemporaryDirectory() as NSString).appendingPathComponent(((outputFileName + "-3") as NSString).appendingPathExtension("ts")!)
////                        self.fileUrl = URL(fileURLWithPath: outputFilePath3)
////                        movieFileOutput.stopRecording()
////                        movieFileOutput.startRecording(to: self.fileUrl!, recordingDelegate: self)
////                    }
////                }
////            }
////        } else {
////            movieFileOutput.stopRecording()
////        }
//    }
//
//    public func toggleMovieRecording() {
//        setRecording(!(movieFileOutput?.isRecording ?? true))
//    }
//
//    /// - Tag: DidStartRecording
//    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
//        print("Started......")
//    }
//
//    /// - Tag: DidFinishRecording
//    func fileOutput(_ output: AVCaptureFileOutput,
//                    didFinishRecordingTo outputFileURL: URL,
//                    from connections: [AVCaptureConnection],
//                    error: Error?) {
//        print("Finished......")
//    }
//
//    // MARK: KVO and Notifications
//
//    private var keyValueObservations = [NSKeyValueObservation]()
//    /// - Tag: ObserveInterruption
//    private func addObservers() {
//        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
//            guard let isSessionRunning = change.newValue else { return }
//            print("SESSION RUNNING: \(isSessionRunning)")
//        }
//        keyValueObservations.append(keyValueObservation)
//
//        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
//            guard let systemPressureState = change.newValue else { return }
//            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
//        }
//        keyValueObservations.append(systemPressureStateObservation)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(subjectAreaDidChange),
//                                               name: .AVCaptureDeviceSubjectAreaDidChange,
//                                               object: videoDeviceInput.device)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(sessionRuntimeError),
//                                               name: .AVCaptureSessionRuntimeError,
//                                               object: session)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(sessionWasInterrupted),
//                                               name: .AVCaptureSessionWasInterrupted,
//                                               object: session)
//    }
//
//    private func removeObservers() {
//        NotificationCenter.default.removeObserver(self)
//
//        for keyValueObservation in keyValueObservations {
//            keyValueObservation.invalidate()
//        }
//        keyValueObservations.removeAll()
//    }
//
//    @objc
//    func subjectAreaDidChange(notification: NSNotification) {
//        let devicePoint = CGPoint(x: 0.5, y: 0.5)
//        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
//    }
//
//    /// - Tag: HandleRuntimeError
//    @objc
//    func sessionRuntimeError(notification: NSNotification) {
//        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
//
//        print("Capture session runtime error: \(error)")
//        // If media services were reset, and the last start succeeded, restart the session.
//        if error.code == .mediaServicesWereReset {
//            sessionQueue.async {
//                if self.isSessionRunning {
//                    self.session.startRunning()
//                    self.isSessionRunning = self.session.isRunning
//                } else {
//                }
//            }
//        } else {
//        }
//    }
//
//    /// - Tag: HandleSystemPressure
//    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
//        /*
//         The frame rates used here are only for demonstration purposes.
//         Your frame rate throttling may be different depending on your app's camera configuration.
//         */
//        let pressureLevel = systemPressureState.level
//        if pressureLevel == .serious || pressureLevel == .critical {
//            if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
//                do {
//                    try self.videoDeviceInput.device.lockForConfiguration()
//                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
//                    self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
//                    self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
//                    self.videoDeviceInput.device.unlockForConfiguration()
//                } catch {
//                    print("Could not lock device for configuration: \(error)")
//                }
//            }
//        } else if pressureLevel == .shutdown {
//            print("Session stopped running due to shutdown system pressure level.")
//        }
//    }
//
//    @objc func sessionWasInterrupted(notification: NSNotification) {
//        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
//            let reasonIntegerValue = userInfoValue.integerValue,
//            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
//            print("Capture session was interrupted with reason \(reason)")
//        }
//    }
//}
//
//extension AVCaptureVideoOrientation {
//    init?(deviceOrientation: UIDeviceOrientation) {
//        switch deviceOrientation {
//        case .portrait: self = .portrait
//        case .portraitUpsideDown: self = .portraitUpsideDown
//        case .landscapeLeft: self = .landscapeRight
//        case .landscapeRight: self = .landscapeLeft
//        default: return nil
//        }
//    }
//
//    init?(interfaceOrientation: UIInterfaceOrientation) {
//        switch interfaceOrientation {
//        case .portrait: self = .portrait
//        case .portraitUpsideDown: self = .portraitUpsideDown
//        case .landscapeLeft: self = .landscapeLeft
//        case .landscapeRight: self = .landscapeRight
//        default: return nil
//        }
//    }
//}
//
//extension AVCaptureDevice.DiscoverySession {
//    var uniqueDevicePositionsCount: Int {
//
//        var uniqueDevicePositions = [AVCaptureDevice.Position]()
//
//        for device in devices where !uniqueDevicePositions.contains(device.position) {
//            uniqueDevicePositions.append(device.position)
//        }
//
//        return uniqueDevicePositions.count
//    }
//}
//
////import AVFoundation
////import AssetsLibrary
//
////class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
////    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//////        library.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: { (assetURL: NSURL?, error: NSError?) -> Void in
//////            if (error != nil) {
//////                print("Unable to save video to the iPhone \(error!.localizedDescription)")
//////            }
//////        })
////        print(outputFileURL.absoluteString)
////    }
////
////
////    var captureSession = AVCaptureSession()
////
////    lazy var frontCameraDevice: AVCaptureDevice? = {
////        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
////        return devices.filter{$0.position == .front}.first
////    }()
////
////    lazy var micDevice: AVCaptureDevice? = {
////        return AVCaptureDevice.default(for: AVMediaType.audio)
////    }()
////
////    var movieOutput = AVCaptureMovieFileOutput()
////
////    private var tempFilePath: URL = {
////        let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie")?.appendingPathExtension("mp4").absoluteString
////        if FileManager.default.fileExists(atPath: tempPath!) {
////            do {
////                try FileManager.default.removeItem(atPath: tempPath!)
////            } catch { }
////        }
////        return URL(string: tempPath!)!
////    }()
////
////    private var tempFilePath2: URL = {
////        let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie2")?.appendingPathExtension("mp4").absoluteString
////        if FileManager.default.fileExists(atPath: tempPath!) {
////            do {
////                try FileManager.default.removeItem(atPath: tempPath!)
////            } catch { }
////        }
////        return URL(string: tempPath!)!
////    }()
////
////    private var tempFilePath3: URL = {
////        let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie3")?.appendingPathExtension("mp4").absoluteString
////        if FileManager.default.fileExists(atPath: tempPath!) {
////            do {
////                try FileManager.default.removeItem(atPath: tempPath!)
////            } catch { }
////        }
////        return URL(string: tempPath!)!
////    }()
////
////    private var tempFilePath4: URL = {
////        let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie4")?.appendingPathExtension("mp4").absoluteString
////        if FileManager.default.fileExists(atPath: tempPath!) {
////            do {
////                try FileManager.default.removeItem(atPath: tempPath!)
////            } catch { }
////        }
////        return URL(string: tempPath!)!
////    }()
////
////    private var tempFilePath5: URL = {
////        let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie5")?.appendingPathExtension("mp4").absoluteString
////        if FileManager.default.fileExists(atPath: tempPath!) {
////            do {
////                try FileManager.default.removeItem(atPath: tempPath!)
////            } catch { }
////        }
////        return URL(string: tempPath!)!
////    }()
////
//////    private var library = PHPhotoLibrary()
////
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        //start session configuration
////        captureSession.beginConfiguration()
////        captureSession.sessionPreset = AVCaptureSession.Preset.high
////
////        // add device inputs (front camera and mic)
////        captureSession.addInput(deviceInputFromDevice(device: frontCameraDevice)!)
////        captureSession.addInput(deviceInputFromDevice(device: micDevice)!)
////
////        // add output movieFileOutput
////        movieOutput.movieFragmentInterval = CMTime(value: 1, timescale: 1)
////        captureSession.addOutput(movieOutput)
////
////        // start session
////        captureSession.commitConfiguration()
////        captureSession.startRunning()
////    }
////
////    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        print("touch")
////        movieOutput.startRecording(to: tempFilePath, recordingDelegate: self)
////    }
////
////    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////        print("release")
////        //stop capture
////        movieOutput.stopRecording()
////    }
////
////    private func deviceInputFromDevice(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
////        guard let validDevice = device else { return nil }
////        do {
////            return try AVCaptureDeviceInput(device: validDevice)
////        } catch let outError {
////            print("Device setup error occured \(outError)")
////            return nil
////        }
////    }
//////
//////    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
//////    }
//////
//////    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
//////        if (error != nil)
//////        {
//////            print("Unable to save video to the iPhone  \(error.localizedDescription)")
//////        }
//////        else
//////        {
//////            // save video to photo album
//////            library.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: { (assetURL: NSURL?, error: NSError?) -> Void in
//////                if (error != nil) {
//////                    print("Unable to save video to the iPhone \(error!.localizedDescription)")
//////                }
//////            })
//////
//////        }
//////    }
////}

import UIKit
import AVFoundation
import Photos
import Swifter
import AVKit

class PlayerViewController: UIViewController {
    weak var player: AVPlayer?
    weak var playerViewController: AVPlayerViewController?
    var url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPlayer()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscapeLeft
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .landscapeLeft
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerViewController?.view.frame = view.bounds
    }
    
    func addPlayer() {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.videoGravity = .resizeAspectFill
        player.rate = 1
        playerViewController.view.frame = view.bounds
        
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
    }
}

class CameraViewController: UIViewController,
                            AVCaptureVideoDataOutputSampleBufferDelegate,
                            AVCaptureAudioDataOutputSampleBufferDelegate,
                            AVAssetWriterDelegate {
    private enum SessionSetupResult {
        case authorized
        case notAuthorized
        case configurationFailed
    }
    
    private var cameraAccess: SessionSetupResult = .authorized
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let configuration = FMP4WriterConfiguration()
    private let session = AVCaptureSession()
    
    private let videoQueue: DispatchQueue = DispatchQueue(label: "VideoOutputQueue")
    private let audioQueue: DispatchQueue = DispatchQueue(label: "AudioOutputQueue")
    private let videoInputQueue: DispatchQueue = DispatchQueue(label: "VideoInputQueue")
    private let audioInputQueue: DispatchQueue = DispatchQueue(label: "AudioInputQueue")
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let mergeQueue = DispatchQueue(label: "merge queue")
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    lazy private var movieBufferOutput = AVCaptureVideoDataOutput()
    lazy private var audioBufferOutput = AVCaptureAudioDataOutput()
    private var movieConnection: AVCaptureConnection!
    private var audioConnection: AVCaptureConnection!
    private var assetWriter: AVAssetWriter! = nil
    private var assetWriterInput: AVAssetWriterInput! = nil
    private var audioWriterInput: AVAssetWriterInput! = nil
    private var chunkNumber = 0
    private let chunkMaxDuration = 8.0
    private var chunkStartTime: CMTime! = nil
    private var chunkOutputURL: URL! = nil
    private var stopRecording: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startHttpServer()
        addPreviewLayer()
        requestCameraAccess()
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showCameraAccessAlertIfNeeded()
        DispatchQueue.global(qos: .userInitiated)
            .async { [weak self] in
                self?.cleanupOldTransportStreams()
            }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        videoPreviewLayer?.frame = view.frame
        if let videoPreviewLayerConnection = videoPreviewLayer?.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                  deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                return
            }
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
    
    //MARK: - Setup
    
    var server: HttpServer!
    private func startHttpServer() {
        server = HttpServer()
        server["/:path"] = shareFilesFromDirectory(NSTemporaryDirectory())
        try? server.start(80)
    }
    
    private func addPreviewLayer() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:))))
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.backgroundColor = UIColor.black.cgColor
        videoPreviewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer!)
    }
    
    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.cameraAccess = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            cameraAccess = .notAuthorized
        }
    }
    
    private func configureSession() {
        if cameraAccess != .authorized {
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        do {
            let device: AVCaptureDevice =
                AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ??
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
            let videoDeviceInput = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                cameraAccess = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            cameraAccess = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        let audioDevice = AVCaptureDevice.default(for: .audio)
        if let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!),
           session.canAddInput(audioDeviceInput) {
            session.addInput(audioDeviceInput)
        }
        
        movieBufferOutput.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        
        if self.session.canAddOutput(movieBufferOutput) {
            self.session.addOutput(movieBufferOutput)
            
            if let connection = self.movieBufferOutput.connection(with: .video) {
                movieConnection = connection
                let deviceOrientation = UIDevice.current.orientation
                let orientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation)
                connection.videoOrientation = orientation ?? .landscapeRight
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
        } else {
            cameraAccess = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        if self.session.canAddOutput(audioBufferOutput) {
            self.session.addOutput(audioBufferOutput)
            if let connection = self.audioBufferOutput.connection(with: .audio) {
                audioConnection = connection
            }
        } else {
            cameraAccess = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        self.movieBufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        self.audioBufferOutput.setSampleBufferDelegate(self, queue: audioQueue)
        self.movieBufferOutput.alwaysDiscardsLateVideoFrames = true
        
        session.commitConfiguration()
        createWriterInput()
        self.session.startRunning()
    }
    
    func cleanupOldTransportStreams() {
        let chunksDir = NSTemporaryDirectory()
        var isDirectory = ObjCBool(true)
        guard FileManager.default.fileExists(atPath: chunksDir, isDirectory: &isDirectory) else { return }
        let chunksDirUrl = URL(fileURLWithPath: chunksDir)
        let directoryContents = try? FileManager.default
            .contentsOfDirectory(at: chunksDirUrl,
                                 includingPropertiesForKeys: [.contentModificationDateKey],
                                 options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        
        let tsFiles = (directoryContents ?? [])
            .filter { $0.pathExtension == "ts" }
            .map { ($0, (try? $0.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast) }
            .sorted(by: { $0.1 < $1.1 })
        
        for ts in tsFiles {
            try? FileManager.default.removeItem(at: ts.0)
        }
    }
    
    //MARK: - Alerts
    
    private func showCameraAccessAlertIfNeeded() {
        sessionQueue.async {
            switch self.cameraAccess {
            case .authorized:
                break
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = "We're not allowed to use your camera.\nYou must change your camera settings before starting this stream."
                    let alertController = UIAlertController(title: "Not authorized", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = "Oups... Something went wrong."
                    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - Gesture Handlers
    
    @objc private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let devicePoint = videoPreviewLayer?
                .captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view)) else { return }
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    func createWriterInput() {
        assetWriter = AVAssetWriter(contentType: UTType(configuration.outputContentType.rawValue)!)
        assetWriter.delegate = self
        
        audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: configuration.audioCompressionSettings)
        audioWriterInput.expectsMediaDataInRealTime = true
        assetWriter.add(audioWriterInput)
        
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: configuration.videoCompressionSettings)
        assetWriterInput.expectsMediaDataInRealTime = true
        assetWriter.add(assetWriterInput)
        
        chunkNumber += 1
        assetWriter.shouldOptimizeForNetworkUse = true
        assetWriter.outputFileTypeProfile = configuration.outputFileTypeProfile
        assetWriter.preferredOutputSegmentInterval = CMTime(seconds: Double(configuration.segmentDuration), preferredTimescale: 1)
        assetWriter.initialSegmentStartTime = configuration.startTimeOffset
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: configuration.startTimeOffset)
    }
    
    func setRecording(_ enabled: Bool = true) {
        stopRecording = !enabled
    }
    
    func assetWriter(_ writer: AVAssetWriter,
                     didOutputSegmentData segmentData: Data,
                     segmentType: AVAssetSegmentType,
                     segmentReport: AVAssetSegmentReport?) {
        let isInitializationSegment: Bool
        
        switch segmentType {
        case .initialization:
            isInitializationSegment = true
        case .separable:
            isInitializationSegment = false
        @unknown default:
            print("Skipping segment with unrecognized type \(segmentType)")
            return
        }
        
        let segment = Segment(index: Segment.lastIndexFound,
                data: segmentData,
                isInitializationSegment: isInitializationSegment,
                report: segmentReport)
        segment.write()
        let name = segment.fileName(forPrefix: FMP4WriterConfiguration().segmentFileNamePrefix)
        Segment.lastIndexFound += 1
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection == self.audioConnection {
            if let audioInput = self.audioWriterInput, audioInput.isReadyForMoreMediaData {
                if !audioInput.append(sampleBuffer) {
                    print("Error writing audio buffer");
                }
            }
        } else if connection == self.movieConnection {
            if let videoInput = self.assetWriterInput, videoInput.isReadyForMoreMediaData {
                if !videoInput.append(sampleBuffer) {
                    print(assetWriter.error)
                }
            }
        }
    }
}

struct Segment {
    static var previousReport: (String, AVAssetSegmentTrackReport)?
    static var m3u8 = M3U()
    static var lastIndexFound = 0
    static var sequence: Int = 0
    static var files: [M3UMediaInfo] = []
    
    let index: Int
    let data: Data
    let isInitializationSegment: Bool
    let report: AVAssetSegmentReport?
    
    func fileName(forPrefix prefix: String) -> String {
        let fileExtension: String
        if isInitializationSegment {
            fileExtension = "mp4"
        } else {
            fileExtension = "m4s"
        }
        return "\(prefix)\(index).\(fileExtension)"
    }
    
    func write() {
        let fileManager = FileManager.default
        
        let chunkName = fileName(forPrefix: FMP4WriterConfiguration().segmentFileNamePrefix)
        let chunkUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(chunkName)
        let playlistUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("playlist")
            .appendingPathExtension("m3u8")
        let playlistLLHLSUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("playlist-llhls")
            .appendingPathExtension("m3u8")
        try? fileManager.removeItem(at: chunkUrl)
        try? data.write(to: chunkUrl)
        try? resolveM3U8File().write(to: playlistUrl, atomically: false, encoding: .utf8)
        try? resolveM3U8File(llhls: true).write(to: playlistLLHLSUrl, atomically: false, encoding: .utf8)
    }
    
    func resolveM3U8File(llhls: Bool = false) -> String {
        let fileName = self.fileName(forPrefix: FMP4WriterConfiguration().segmentFileNamePrefix)
        if !isInitializationSegment {
            let segmentReport = report!
            let timingTrackReport = segmentReport.trackReports.first(where: { $0.mediaType == .video })!
            if let previousSegmentInfo = Self.previousReport {
                let segmentDuration = timingTrackReport.earliestPresentationTimeStamp - previousSegmentInfo.1.earliestPresentationTimeStamp
                Self.files.append(.init(url: previousSegmentInfo.0, duration: segmentDuration))
            }
            Self.previousReport = (fileName, timingTrackReport)
        } else {
            Self.m3u8.firstElement = fileName
        }
        
        Self.m3u8.targetDuration = Double(FMP4WriterConfiguration().segmentDuration)
        Self.m3u8.mediaList = Self.files
        return llhls ? Self.m3u8.descriptionLLHLS : Self.m3u8.description
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }

    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions = [AVCaptureDevice.Position]()

        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }

        return uniqueDevicePositions.count
    }
}

import VideoToolbox

struct FMP4WriterConfiguration {
    let outputContentType = AVFileType.mp4
    let outputFileTypeProfile = AVFileTypeProfile.mpeg4AppleHLS
    let segmentDuration = 1.0
    var segmentFileNamePrefix = "fileSequence"
    
    let startTimeOffset = CMTime(value: 0, timescale: 1)
    
    let audioCompressionSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44_100,
        AVNumberOfChannelsKey: 2,
        AVEncoderBitRateKey: 160_000
    ]
    
    let videoCompressionSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: 1920,
        AVVideoHeightKey: 1080,
        AVVideoCompressionPropertiesKey: [
            AVVideoMaxKeyFrameIntervalKey: 2,
            kVTCompressionPropertyKey_AverageBitRate: 6_000_000,
            kVTCompressionPropertyKey_ProfileLevel: AVVideoProfileLevelH264HighAutoLevel
        ]
    ]
}

struct M3U {
    static let header: String = "#EXTM3U"
    static let defaultVersion: Int = 9

    var firstElement: String?
    var version: Int = M3U.defaultVersion
    var mediaList: [M3UMediaInfo] = []
    var targetDuration: Double = 5
}

extension M3U: CustomStringConvertible {
    var description: String {
        var lines: [String] = [
            "#EXTM3U",
            "#EXT-X-VERSION: \(version)",
            "#EXT-X-MEDIA-SEQUENCE: 0",
            "#EXT-X-TARGETDURATION: \(Int(targetDuration))",
//            "#EXT-X-SERVER-CONTROL:CAN-BLOCK-RELOAD=NO,PART-HOLD-BACK=1.0,CAN-SKIP-UNTIL=1.0",
            "#EXT-X-PART-INF:PART-TARGET= \(Int(targetDuration))",
            "#EXT-X-MEDIA-SEQUENCE: 0"
        ]
        if let firstElement = self.firstElement {
            lines.append("#EXT-X-MAP:URI=\"\(firstElement)\"")
        }
        for info in mediaList {
            lines.append("#EXTINF: \(String(format: "%1.5f", info.duration.seconds)),")
            lines.append(info.url)
        }
//        for info in mediaList {
//            lines.append("#EXT-X-PART:DURATION=\(String(format: "%1.5f", info.duration.seconds)),URI=\"\(info.url)\",INDEPENDENT=YES")
//        }
        let test = lines.joined(separator: "\n")
        print(test)
        return test
    }
    
    var descriptionLLHLS: String {
        var lines: [String] = [
            "#EXTM3U",
            "#EXT-X-VERSION: \(version)",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-TARGETDURATION: \(Int(targetDuration))",
            "#EXT-X-SERVER-CONTROL:CAN-BLOCK-RELOAD=NO,PART-HOLD-BACK=1.0,CAN-SKIP-UNTIL=1.0",
            "#EXT-X-PART-INF:PART-TARGET= \(Int(targetDuration))",
            "#EXT-X-MEDIA-SEQUENCE: 0",
            "#EXT-X-PROGRAM-DATE-TIME:2019-12-23T02:29:02.609Z"
        ]
        if let firstElement = self.firstElement {
            lines.append("#EXT-X-MAP:URI=\"\(firstElement)\"")
        }
        for info in mediaList {
            lines.append("#EXT-X-PART:DURATION=\(String(format: "%1.5f", info.duration.seconds)),URI=\"\(info.url)\",INDEPENDENT=YES")
        }
        if let firstElement = self.firstElement {
            lines.append("\(firstElement)")
        }
        let test = lines.joined(separator: "\n")
        print(test)
        return test
    }
}

struct M3UMediaInfo {
    let url: String
    let duration: CMTime
}
