//
//  GameViewController.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 29.12.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import SpriteKit
import Speech

struct isOutsideStruct {
    var top: Bool
//    var topTimer: Timer
    var bottom: Bool
//    var bottomTimer: Timer
    var left: Bool
//    var leftTimer: Timer
    var right: Bool
//    var righTimer: Timer
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var backgroundView: UIView!
    
    private var isOutside = isOutsideStruct(top: false, bottom: false, left: false, right: false)
    private var headGazeRecognizer: UIHeadGazeRecognizer? = nil
    
    
    var voiceControlDeleget: GameScenceControlDelegate? = nil
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupGestureRecognizer()
                
        let scene = GameScene(size: skview.bounds.size)
        
        scene.backgroundColor = .clear
        scene.scaleMode = .fill
        
        voiceControlDeleget = scene
        skview.presentScene(scene)
        skview.ignoresSiblingOrder = true
        skview.showsFPS = true
        skview.showsNodeCount = true
        skview.allowsTransparency = true
    }
    
    private func setupGestureRecognizer() {
        self.headGazeRecognizer = UIHeadGazeRecognizer()
        //super.virtualCursorView?.smoothness = 4
        //super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
        headGazeRecognizer!.move = { [weak self] gaze in
            self?.moveAction(gaze: gaze)
        }
    }
    
    private func moveAction(gaze: UIHeadGaze){
        if true {
            let localCursorPos = gaze.location(in: self.skview)
            
            let isOutsideLeft = localCursorPos.x < 0
            if !self.isOutside.left && isOutsideLeft {
                // just went outside
//                self.isOutside.leftTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
//                    // ignore next
//                }
            }
            if self.isOutside.left && !isOutsideLeft {
                // came back
//                let timer =
                self.voiceControlDeleget!.shiftLeft()
            }
            self.isOutside.left = isOutsideLeft
            
            let isOutsideRight = localCursorPos.x > 300
            if self.isOutside.right && !isOutsideRight {
                self.voiceControlDeleget!.shiftRight()
            }
            self.isOutside.right = isOutsideRight
            
            let isOutsideTop = localCursorPos.y < 100
            if self.isOutside.top && !isOutsideTop {
                self.voiceControlDeleget!.shiftUp()
            }
            self.isOutside.top = isOutsideTop
            
            let isOutsideBottom = localCursorPos.y > 540
            if self.isOutside.bottom && !isOutsideBottom {
                self.voiceControlDeleget!.shiftDown()
            }
            self.isOutside.bottom = isOutsideBottom
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        backgroundView.layer.addSublayer(videoPreviewLayer)
        
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
           DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.skview.bounds
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
}
