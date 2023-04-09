//
 

import Foundation
import UIKit
import AVFoundation
import SPPermissions
import MobileCoreServices

class CameraHistoryViewController: UIViewController {
    
    // MARK: - Variables
    private let captureSession = AVCaptureSession()
    private let photoFileOutput = AVCapturePhotoOutput()
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    private let delegate: ImagePickerDelegate
    
    // MARK: - Outlets
    private let closeButton = UIButtonFactory()
        .tint(color: .white)
        .set(image: Icons.General.cancel)
        .setImage(size: 34)
        .background(color: .clear)
        .addTarget(#selector(back))
        .build()
    
    private let recordButton = UIButtonFactory()
        .tint(color: .white)
        .set(image: Icons.Camera.shootButton)
        .setImage(size: 44)
        .background(color: .clear)
        .addTarget(#selector(didTakePhoto))
        .build()
    
    private let switchCameraButton = UIButtonFactory()
        .tint(color: .white)
        .set(image: Icons.Camera.switchCamera)
        .setImage(size: 34)
        .background(color: .clear)
        .addTarget(#selector(switchCamera))
        .build()
    
    private let captureImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // MARK: - LifeCycle
    init(delegate: ImagePickerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupUI()
        
        recordButton.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(gestureRecognizer:))))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    
    // MARK: - Actions
    @objc private func didTakePhoto() {
        let settings = AVCapturePhotoSettings()
        self.photoFileOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func switchCamera() {
        captureSession.beginConfiguration()
        
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        let newCameraDevice = currentInput?.device.position == .back ? getDevice(position: .front) : getDevice(position: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        
        let captureAudio = AVCaptureDevice.default(for: AVMediaType.audio)
        let inputAudio = try? AVCaptureDeviceInput(device: captureAudio!)
        
        // Remove all current inputs
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        if captureSession.inputs.isEmpty {
            captureSession.addInput(newVideoInput!)
            captureSession.addInput(inputAudio!)
        }
        captureSession.commitConfiguration()
    }
    
    @objc private func back() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            // Long progress start
            recordButton.tintColor = .red
            recordButton.setImage(Icons.Camera.recordButton, for: .normal)
            
            // Switch photo to video
            captureSession.removeOutput(photoFileOutput)
            captureSession.addOutput(movieFileOutput)
            
            // Create video file
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsURL.appendingPathComponent("tempMovie.mp4")
            if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: filePath)
                }
                catch {
                    // exception while deleting old cached file
                    // ignore error if any
                }
            }
            movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            
            recordButton.tintColor = .white
            recordButton.setImage(Icons.Camera.shootButton, for: .normal)
            
            captureSession.removeOutput(movieFileOutput)
            captureSession.addOutput(photoFileOutput)
            movieFileOutput.stopRecording()
        }
    }
    
    // MARK: - Methods
    private func setupCaptureSession() {
        guard let captureVideoDevice = AVCaptureDevice.default(for: AVMediaType.video),
        let captureAudioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else { return }
        do {
            let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
            let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
            if captureSession.canAddInput(inputVideo) {
                captureSession.addInput(inputVideo)
            }
            if captureSession.canAddInput(inputAudio) {
                captureSession.addInput(inputAudio)
            }
        } catch let error {
            debugPrint("Could not setup camera input:", error)
        }

        if captureSession.canAddOutput(photoFileOutput){
            captureSession.addOutput(photoFileOutput)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [captureImageView, recordButton, switchCameraButton, closeButton].forEach {
            view.addSubview($0)
        }
        
        captureImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.width.height.equalTo(44)
        }
        
        recordButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        switchCameraButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(recordButton)
            make.trailing.equalToSuperview().inset(32)
            make.width.height.equalTo(44)
        }
        
    }
    
}

extension CameraHistoryViewController: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let previewImage = UIImage(data: photo.fileDataRepresentation()!){
            delegate.didSelect(image: previewImage)
            back()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        delegate.didSelect(url: outputFileURL)
        back()
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: [AVCaptureDevice] = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera], mediaType: .video, position: position).devices
        for de in devices {
            let deviceConverted = de
            if (deviceConverted.position == position){
               return deviceConverted
            }
        }
       return nil
    }
}


