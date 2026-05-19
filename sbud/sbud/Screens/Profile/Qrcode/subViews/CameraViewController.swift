//
//  CameraViewController.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import AVFoundation
import Vision

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let onScanned: (String) -> Void
    private let onPermissionDenied: () -> Void

    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    private let videoQueue = DispatchQueue(label: "sbud.camera.queue", qos: .userInitiated)

    init(onScanned: @escaping (String) -> Void,
         onPermissionDenied: @escaping () -> Void) {
        self.onScanned = onScanned
        self.onPermissionDenied = onPermissionDenied
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkPermissionAndSetup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let session, !session.isRunning {
            videoQueue.async { session.startRunning() }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.setupSession() : self?.onPermissionDenied()
                }
            }
        default:
            DispatchQueue.main.async { self.onPermissionDenied() }
        }
    }

    private func setupSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { session.commitConfiguration(); return }

        session.addInput(input)

        // Use video data output + Vision instead of metadata output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(videoOutput)

        // Fix orientation — set connection to portrait
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }

        session.commitConfiguration()

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        self.session      = session
        self.previewLayer = preview
        // Don't start here — viewDidAppear handles it
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !hasScanned,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        let request = VNDetectBarcodesRequest { [weak self] req, error in
            guard let self else { return }

            if let error {
                print("Vision error: \(error)")
                return
            }

            guard
                let results = req.results as? [VNBarcodeObservation],
                let barcode = results.first(where: { $0.symbology == .qr }),
                let value   = barcode.payloadStringValue,
                !value.isEmpty
            else { return }

            guard !self.hasScanned else { return }
            self.hasScanned = true
            self.session?.stopRunning()

            print("📷 Scanned: \(value)")

            DispatchQueue.main.async {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                self.onScanned(value)
            }
        }

        // Tell Vision the image is already upright (we rotated the connection above)
        request.symbologies = [.qr]

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .up,  // connection is rotated to portrait already
            options: [:]
        )

        try? handler.perform([request])
    }
}
