//
//  ViewController.swift
//  CustomCamera
//
//  Created by Adarsh V C on 06/10/16.
//  Copyright © 2016 FAYA Corporation. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Alamofire
class ViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imgOverlay: UIImageView!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var debugLabel: UILabel?
    var gameTimer: Timer!
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var satus:Bool = false
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.back) {
                        captureDevice = device
                        if captureDevice != nil {
                            print("Capture device found")
                            beginSession()
                            
                           
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func actionCameraCapture(_ sender: AnyObject) {
        
        //print("Camera button pressed")
        //saveToCamera()
        // gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(saveToCamera), userInfo: nil, repeats: true)
        if(satus == false){
            startTimer()
        }else {
            
            stopTimer()
        }
    }
    
    func startTimer () {
       
        if gameTimer == nil {
            saveToCamera()
            gameTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(saveToCamera), userInfo: nil, repeats: true)
            satus = true
            self.btnCapture.backgroundColor = UIColor.gray
            self.debugLabel?.text = "startTimer"
        }
    }
    
    func stopTimer() {
        print("Camera button pressed")
        if gameTimer != nil {
            gameTimer.invalidate()
            gameTimer = nil
            satus = false
            self.btnCapture.backgroundColor = UIColor.clear
            self.debugLabel?.text = "stopTimer"
        }
    }
    func beginSession() {
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
            print("no preview layer")
            return
        }
        
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        
        self.view.addSubview(navigationBar)
        self.view.addSubview(imgOverlay)
        self.view.addSubview(btnCapture)
    }
    
    func saveToCamera() {
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            self.debugLabel?.text = "saveToCamera"
             print("saveToCamera")
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        
                        let imageData :Data! = UIImageJPEGRepresentation(cameraImage, 0.75)
                        
                        Alamofire.upload(multipartFormData: { multipartFormData in
                            multipartFormData.append(imageData, withName: "img",fileName: "test.jpg", mimeType: " image/jpeg")
                            //for (key, value) in Parameters {
                              //  multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                            //} //Optional for extra parameters
                        },to:"http://airg19-api2.southeastasia.cloudapp.azure.com/api/upload-img")
                        { (result) in
                            switch result {
                            case .success(let upload, _, _):
                                
                                upload.uploadProgress(closure: { (progress) in
                                  
                                })
                                
                                upload.validate().responseString { response in
                                
                                    
                                    var httpStatusCode = 0
                                    if let code = (response.response?.statusCode)  {
                                        httpStatusCode = code
                                    }
                                    
                                    
                                    if( httpStatusCode == 200){
                                     self.debugLabel?.text = "upload ok"
                                    }
                                    
                                }
                         
                               
                            case .failure(_):
                               debugPrint("fail")
                            }
                        }

                        
                        
                        UIImageWriteToSavedPhotosAlbum(cameraImage, nil, nil, nil)                        
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

