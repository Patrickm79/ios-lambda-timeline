//
//  CamSetupVC.swift
//  LambdaTimeline
//
//  Created by Patrick Millet on 6/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraSetupViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: get permission
        requestPremissionAndShowCamera()
        showCamera()
    }
    
    
    private func requestPremissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showCamera()
        case .denied:
            let alertController = UIAlertController()
            // TODO: Take user to settings
            let alertAction = UIAlertAction(title: "This application needs camera permission to record your video message.", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        case .notDetermined:
            requestCameraPermission()
        case .restricted:
            let restrictedAlertController = UIAlertController()
            let restrictedAction = UIAlertAction(title: "There are restrictions preventing you from using the camera, please check with an authorized user.", style: .default, handler: nil)
            restrictedAlertController.addAction(restrictedAction)
            present(restrictedAlertController, animated: true, completion: nil)
        @unknown default:
            fatalError("Unknown response to video authorization check")
        }
    }
    
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            guard granted else {
                let alertController = UIAlertController()
                // TODO: Take user to settings
                let alertAction = UIAlertAction(title: "This application needs camera permission to record your video message.", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
}
