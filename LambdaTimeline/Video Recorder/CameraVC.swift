//
//  CameraVC.swift
//  LambdaTimeline
//
//  Created by Patrick Millet on 6/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    private var playerView: VideoPlayerView!
    private var videoPlayer: AVPlayer?
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setUpCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func setUpCaptureSession() {
        
        captureSession.beginConfiguration()
        
        guard let camera = bestCamera() else { return }
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                
                let alertController = UIAlertController()
                let cameraInputFailure = UIAlertAction(title: "There is an issue with the camera hardware, please try again.", style: .default, handler: nil)
                alertController.addAction(cameraInputFailure)
                present(alertController, animated: true, completion: nil)
                return
                
        }
        captureSession.addInput(cameraInput)
        
        guard let microphone = bestAudio() else { return }
        
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                let alertController = UIAlertController()
                let microphoneInputFailure = UIAlertAction(title: "There is an issue getting the microphone working, please try again.", style: .default, handler: nil)
                alertController.addAction(microphoneInputFailure)
                present(alertController, animated: true, completion: nil)
                return
        }
        
        captureSession.addInput(audioInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        guard captureSession.canAddOutput(fileOutput) else {
            let alertController = UIAlertController()
            let captureSessionFailure = UIAlertAction(title: "There is an issue creating the capture session, please try again.", style: .default, handler: nil)
            alertController.addAction(captureSessionFailure)
            present(alertController, animated: true, completion: nil)
            return
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
        
        captureSession.startRunning()
    }
    
    private func bestCamera() -> AVCaptureDevice? {
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        {
            return wideAngleCamera
        } else {
            
            let alertController = UIAlertController()
            let hardwareFailureAlert = UIAlertAction(title: "There was an error getting the camera hardware information, please try again.", style: .default, handler: nil)
            alertController.addAction(hardwareFailureAlert)
            present(alertController, animated: true, completion: nil)
            return nil
        }
        
    }
    
    private func bestAudio() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        } else {
            let alertController = UIAlertController()
            let hardwareFailureAlert = UIAlertAction(title: "There is an issue getting the microphone working, please try again.", style: .default, handler: nil)
            alertController.addAction(hardwareFailureAlert)
            present(alertController, animated: true, completion: nil)
            return nil
        }
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecording()
    }
    
    private func toggleRecording() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
        updateViews()
    }
    
    
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func playMovie(url: URL) {
        let player = AVPlayer(url: url)
        
        if playerView == nil {
            // setup view
            let playerView = VideoPlayerView()
            playerView.player = player
            
            // customize the frame
            var frame = view.bounds
            frame.size.height = frame.size.height / 4
            frame.size.width = frame.size.width / 4
            frame.origin.y = view.layoutMargins.top
            playerView.frame = frame
            
            view.addSubview(playerView)
            self.playerView = playerView
        }
        player.play()
        self.videoPlayer = player
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Did start recording to URL: \(fileURL.path)")
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving movie recording: \(error)")
            return
        }
        updateViews()
        print("Play movie")
        DispatchQueue.main.async {
            self.playMovie(url: outputFileURL)
        }
    }
    
}
