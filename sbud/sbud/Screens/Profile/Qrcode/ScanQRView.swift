//
//  ScanQRView.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import AVFoundation

struct ScanQRView: View {
    let onScanned: (String) -> Void
    @State private var permissionDenied = false

    var body: some View {
        VStack(spacing: 20) {
            Text("POINT AT A SBUD QR CODE")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(Color("palelime"))
                .tracking(3)

            if permissionDenied {
                CameraPermissionDeniedView()
            } else {
                ZStack {
                    CameraPreviewView(onScanned: onScanned,
                                      onPermissionDenied: { permissionDenied = true })
                        .frame(width: 260, height: 260)
                        .cornerRadius(20)
                        .clipped()

                    // Corner brackets overlay
                    ScannerBrackets()
                        .frame(width: 260, height: 260)
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Corner brackets decoration

private struct ScannerBrackets: View {
    var body: some View {
        ZStack {
            // top-left
            BracketCorner().offset(x: 14, y: 14)
            // top-right
            BracketCorner().rotationEffect(.degrees(90)).offset(x: -14, y: 14)
            // bottom-right
            BracketCorner().rotationEffect(.degrees(180)).offset(x: -14, y: -14)
            // bottom-left
            BracketCorner().rotationEffect(.degrees(270)).offset(x: 14, y: -14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct BracketCorner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Rectangle()
                    .fill(Color("palelime"))
                    .frame(width: 3, height: 28)
                Rectangle()
                    .fill(Color("palelime"))
                    .frame(width: 25, height: 3)
            }
        }
        .frame(width: 28, height: 28, alignment: .topLeading)
    }
}

// MARK: - Camera denied

private struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Camera access is needed to scan QR codes.\nPlease enable it in Settings.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color("palelime"))
        }
        .frame(width: 260, height: 260)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - AVFoundation camera preview
import SwiftUI
import AVFoundation
import Vision

struct CameraPreviewView: UIViewControllerRepresentable {
    let onScanned: (String) -> Void
    let onPermissionDenied: () -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        CameraViewController(onScanned: onScanned, onPermissionDenied: onPermissionDenied)
    }

    func updateUIViewController(_ vc: CameraViewController, context: Context) {}
}

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
