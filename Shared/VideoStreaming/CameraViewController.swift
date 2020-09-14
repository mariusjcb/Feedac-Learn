//
//  RecoderView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 12.09.2020.
//

import UIKit
import AVFoundation
import Photos
import Swifter
import AVKit
import ReplayKit

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerViewController?.view.frame = view.bounds
    }
    
    func addPlayer() {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.videoGravity = .resize
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
    
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    private var cameraAccess: SessionSetupResult = .authorized
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let configuration = FMP4WriterConfiguration()
    private let session = AVCaptureSession()
    
    private let recordQueue: DispatchQueue = DispatchQueue(label: "RecordOutputQueue")
    private let videoQueue: DispatchQueue = DispatchQueue(label: "VideoOutputQueue")
    private let audioQueue: DispatchQueue = DispatchQueue(label: "AudioOutputQueue")
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
    private var rvInput: AVAssetWriterInput! = nil
    
    private let screenRecorder = RPScreenRecorder.shared()
    private let drawView = SwiftyDrawView(frame: .zero)
    
    var usesWhiteboard: Bool = true {
        didSet {
            videoPreviewLayer?.isHidden = usesWhiteboard
            drawView.isHidden = !usesWhiteboard
            drawView.isEnabled = usesWhiteboard
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(drawView)
        self.view.addSubview(activityIndicator)
        activityIndicator.color = UIColor.red.withAlphaComponent(0.001)
        activityIndicator.startAnimating()
        
        startHttpServer()
        addPreviewLayer()
        requestCameraAccess()
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        videoPreviewLayer?.isHidden = usesWhiteboard
        drawView.isHidden = !usesWhiteboard
        drawView.isEnabled = usesWhiteboard
        
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
                videoPreviewLayerConnection.videoOrientation = .portrait
                return
            }
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
        drawView.frame = view.bounds
        activityIndicator.frame.origin = .zero
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        screenRecorder.stopCapture { _ in }
    }
    
    deinit {
        assetWriter.finishWriting { }
        session.stopRunning()
        assetWriterInput = nil
        audioWriterInput = nil
        rvInput = nil
        assetWriter = nil
        
        Segment.previousReport = nil
        Segment.partialSumCheck = CMTime(value: 0, timescale: 1000)
        Segment.m3u8 = M3U()
        Segment.lastIndexFound = 0
        Segment.lastPartialIndexFound = 0
        Segment.sequence = 0
        Segment.files = []
        Segment.partials = [:]
    }
    
    //MARK: - Setup
    
    var server: HttpServer!
    private func startHttpServer() {
        server = HttpServer()
        server["/:path"] = shareFilesFromDirectory(NSTemporaryDirectory())
        try? server.start(80)
    }
    
    private func addPreviewLayer() {
        if !usesWhiteboard {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:))))
        }
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
                connection.videoOrientation = orientation ?? .portrait
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
        if usesWhiteboard {
            createScreenRecorderInput()
        }
        self.session.startRunning()
    }
    
    func createScreenRecorderInput() {
        screenRecorder.startCapture(handler: { [weak self] (sample, bufferType, error) in
            if CMSampleBufferDataIsReady(sample) {
                if (bufferType == .video),
                   let isReadyForMoreMediaData = self?.rvInput?.isReadyForMoreMediaData,
                   isReadyForMoreMediaData == true {
                    self?.rvInput?.append(sample)
                }
            }
        }, completionHandler: { (error) in
            print(error)
        })
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
            .filter { $0.pathExtension == "m4s" || $0.pathExtension == "mp4" || $0.pathExtension == "m3u8" }
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
        
        if !usesWhiteboard {
            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: configuration.audioCompressionSettings)
            audioWriterInput.expectsMediaDataInRealTime = true
            assetWriter.add(audioWriterInput)
            
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: configuration.videoCompressionSettings)
            assetWriterInput.expectsMediaDataInRealTime = true
            assetWriter.add(assetWriterInput)
        } else {
            rvInput = AVAssetWriterInput(mediaType: .video, outputSettings: configuration.screenRecordingCompressionSettings)
            rvInput.expectsMediaDataInRealTime = true
            assetWriter.add(rvInput)
        }
        
        assetWriter.shouldOptimizeForNetworkUse = true
        assetWriter.outputFileTypeProfile = configuration.outputFileTypeProfile
        assetWriter.preferredOutputSegmentInterval = CMTime(value: CMTimeValue(configuration.partialSegment), timescale: 1000)
        assetWriter.initialSegmentStartTime = configuration.startTimeOffset
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: configuration.startTimeOffset)
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
        
        let segment = Segment(index: Segment.lastPartialIndexFound,
                              data: segmentData,
                              isInitializationSegment: isInitializationSegment,
                              report: segmentReport)
        segment.write(queue: mergeQueue)
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !usesWhiteboard else { return }
        if connection == self.audioConnection {
            if let audioInput = self.audioWriterInput, audioInput.isReadyForMoreMediaData {
                if !audioInput.append(sampleBuffer) {
                    print("Error writing audio buffer");
                }
            }
        } else if connection == self.movieConnection {
            if let videoInput = self.assetWriterInput, videoInput.isReadyForMoreMediaData {
                if !videoInput.append(sampleBuffer) {
                    print(assetWriter.error!)
                }
            }
        }
    }
}

struct Segment {
    static var previousReport: (String, AVAssetSegmentTrackReport)?
    static var partialSumCheck: CMTime = CMTime(value: 0, timescale: 1000)
    static var m3u8 = M3U()
    static var lastIndexFound = 0
    static var lastPartialIndexFound = 0
    static var sequence: Int = 0
    static var files: [M3UMediaInfo] = []
    static var partials: [Int: [M3UMediaInfo]] = [:]
    
    let index: Int
    let data: Data
    let isInitializationSegment: Bool
    let report: AVAssetSegmentReport?
    
    func fileName(forPrefix prefix: String, isPartial: Bool = false) -> String {
        let fileExtension: String
        if isInitializationSegment {
            fileExtension = "mp4"
        } else {
            fileExtension = "m4s"
        }
        if isPartial {
            return "\(prefix)\(Self.lastIndexFound).\(index).\(fileExtension)"
        } else {
            return "\(prefix)\(Self.lastIndexFound).\(fileExtension)"
        }
    }
    
    func write(queue: DispatchQueue) {
        let fileManager = FileManager.default
        
        let chunkName = fileName(forPrefix: FMP4WriterConfiguration().segmentFileNamePrefix,
                                 isPartial: isInitializationSegment == false)
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
        try? resolveM3U8File(queue: queue).write(to: playlistUrl, atomically: false, encoding: .utf8)
        try? resolveM3U8File(llhls: true, queue: queue).write(to: playlistLLHLSUrl, atomically: false, encoding: .utf8)
    }
    
    func resolveM3U8File(llhls: Bool = false, queue: DispatchQueue) -> String {
        let fileName = self.fileName(forPrefix: FMP4WriterConfiguration().segmentFileNamePrefix,
                                     isPartial: isInitializationSegment == false)
        if !isInitializationSegment {
            if Self.partials[Self.lastIndexFound] == nil {
                Self.partials[Self.lastIndexFound] = []
            }
            let segmentReport = report!
            let timingTrackReport = segmentReport.trackReports.first(where: { $0.mediaType == .video })!
            if let previousSegmentInfo = Self.previousReport {
                let segmentDuration = CMTimeSubtract(timingTrackReport.earliestPresentationTimeStamp,
                                                     previousSegmentInfo.1.earliestPresentationTimeStamp)
                Self.partialSumCheck = CMTimeAdd(Self.partialSumCheck, segmentDuration)
                if Double(Self.partialSumCheck.value) / 1000 > FMP4WriterConfiguration().segmentDuration * 0.5 {
                    let fileName = self.fileName(forPrefix: FMP4WriterConfiguration().segmentFileNamePrefix, isPartial: false)
                    Self.saveM4SChunck(Self.lastIndexFound, fileName, queue)
                    Self.lastIndexFound += 1
                    Self.lastPartialIndexFound = 0
                    if Self.partials[Self.lastIndexFound] == nil {
                        Self.partials[Self.lastIndexFound] = []
                    }
                    Self.files.append(.init(url: fileName, duration: Self.partialSumCheck, isPartial: false))
                    Self.partialSumCheck = CMTime(value: 0, timescale: 1000)
                }
                if segmentDuration.value > 0 {
                    Self.partials[Self.lastIndexFound]!.append(.init(url: previousSegmentInfo.0,
                                                                     duration: segmentDuration,
                                                                     isPartial: true))
                    Self.lastPartialIndexFound += 1
                } else {
                    Self.partialSumCheck = CMTimeSubtract(Self.partialSumCheck, segmentDuration)
                }
            }
            if timingTrackReport.earliestPresentationTimeStamp.value > 0 {
                Self.previousReport = (fileName, timingTrackReport)
            }
        } else if isInitializationSegment {
            Self.m3u8.firstElement = fileName
            Self.lastPartialIndexFound += 1
        }
        
        Self.m3u8.mediaList = Self.files
        Self.m3u8.partialList = Self.partials
        return llhls ? Self.m3u8.descriptionLLHLS : Self.m3u8.description
    }
    
    private static func saveM4SChunck(_ index: Int, _ name: String, _ queue: DispatchQueue) {
        guard partials.count > index else { return }
        do {
            queue.async {
                let filePath = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(name)
                let elements = (partials[index] ?? []).map {
                    URL(fileURLWithPath: NSTemporaryDirectory())
                        .appendingPathComponent($0.url)
                }
                do {
                    try FileManager().merge(files: elements, to: filePath)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
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
    var partialSegment: Double = 320
    var segmentFileNamePrefix = "fileSequence"
    
    let startTimeOffset = CMTime(value: 0, timescale: 1000)
    
    static var channelLayout: AudioChannelLayout = {
        var layout = AudioChannelLayout()
        layout.mChannelLayoutTag = kAudioFormatProperty_AvailableEncodeChannelLayoutTags
        return layout
    }()
    
    let audioCompressionSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44_100,
        AVNumberOfChannelsKey: 2,
        AVEncoderBitRateKey: 160_000
    ]
    
    let videoCompressionSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: UIScreen.main.bounds.width,
        AVVideoHeightKey: UIScreen.main.bounds.height,
        AVVideoCompressionPropertiesKey: [
            AVVideoMaxKeyFrameIntervalKey: 2,
            kVTCompressionPropertyKey_AverageBitRate: 6_000_000,
            kVTCompressionPropertyKey_ProfileLevel: AVVideoProfileLevelH264HighAutoLevel
        ]
    ]
    
    let screenRecordingAudioCompressionSettings: [String: Any] = [
//        AVNumberOfChannelsKey: 6,
        AVFormatIDKey: kAudioFormatMPEG4AAC_HE,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 128000,
        AVChannelLayoutKey: NSData(bytes: &Self.channelLayout, length: MemoryLayout.size(ofValue: channelLayout))
    ]
    
    let screenRecordingCompressionSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: UIScreen.main.bounds.size.width,
        AVVideoHeightKey: UIScreen.main.bounds.size.height,
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 2300000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264High40
        ]
    ]
}

struct M3U {
    static let header: String = "#EXTM3U"
    static let defaultVersion: Int = 9

    var firstElement: String?
    var version: Int = M3U.defaultVersion
    var mediaList: [M3UMediaInfo] = []
    var partialList: [Int: [M3UMediaInfo]] = [:]
    var partialDuration: Double {
        min(partialList.values.map { $0.map { $0.duration }.max() }.compactMap { $0?.seconds }.max() ?? .infinity,
            FMP4WriterConfiguration().partialSegment)
    }
    var targetDuration: Double {
        max(FMP4WriterConfiguration().segmentDuration * 0.5, 1)
    }
}

extension M3U: CustomStringConvertible {
    private var commonLines: [String] {
        var lines = [
            "#EXTM3U",
            "#EXT-X-VERSION: \(version)",
            "#EXT-X-MEDIA-SEQUENCE: 0",
            "#EXT-X-TARGETDURATION: \(Int(targetDuration))"
        ]
        if let firstElement = self.firstElement {
            lines.append("#EXT-X-MAP:URI=\"\(firstElement)\"")
            lines.append("#EXT-X-PART-INF:PART-TARGET= \(Int(targetDuration))")
        }
        return lines
    }
    
    var description: String {
        var lines = commonLines
        for info in mediaList {
            lines.append("#EXTINF: \(String(format: "%1.5f", CMTimeGetSeconds(info.duration))),")
            lines.append(info.url)
        }
        let test = lines.joined(separator: "\n")
        print(test)
        return test
    }
    
    var descriptionLLHLS: String {
        var lines: [String] = [
            "#EXT-X-SERVER-CONTROL:PART-HOLD-BACK=\(Int(targetDuration) * 3)",
            "#EXT-X-PART-INF:PART-TARGET= \(Int(partialDuration))"
        ]
        for partialKey in partialList.keys.sorted() {
            for partial in partialList[partialKey]! {
                lines.append("#EXT-X-PART:DURATION=\(String(format: "%1.5f", CMTimeGetSeconds(partial.duration))),URI=\"\(partial.url)\",INDEPENDENT=YES")
            }
            guard mediaList.count > partialKey else { continue }
            let info = mediaList[partialKey]
            lines.append("#EXTINF:\(String(format: "%1.5f", CMTimeGetSeconds(info.duration))),")
            lines.append(info.url)
        }
        let test = lines.joined(separator: "\n")
        print(test)
        return test
    }
}

struct M3UMediaInfo {
    let url: String
    let duration: CMTime
    let isPartial: Bool
}

extension FileManager {
    func merge(files: [URL], to destination: URL, chunkSize: Int = 1000000) throws {
        FileManager.default.createFile(atPath: destination.path, contents: nil, attributes: nil)
        let writer = try FileHandle(forWritingTo: destination)
        try files.forEach({ partLocation in
            let reader = try FileHandle(forReadingFrom: partLocation)
            var data = reader.readData(ofLength: chunkSize)
            while data.count > 0 {
                writer.write(data)
                data = reader.readData(ofLength: chunkSize)
            }
            reader.closeFile()
        })
        writer.closeFile()
    }
}
