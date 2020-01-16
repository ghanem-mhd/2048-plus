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

class GameViewController: UIHeadGazeViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var skview: SKView!
//    @IBOutlet weak var myButton: UIBubbleButton!
    @IBOutlet weak var recordButton: UIButton!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var isOutside = isOutsideStruct(top: false, bottom: false, left: false, right: false)
    
    private var headGazeRecognizer: UIHeadGazeRecognizer? = nil
    
    
    var voiceControlDeleget: GameScenceControlDelegate? = nil
    
    
    var oldResult:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.skview.allowsTransparency = true
        
        setupGestureRecognizer()
        
        recordButton.isEnabled = false
        
        let scene = GameScene(size: skview.bounds.size)
        voiceControlDeleget = scene
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .black
        skview.presentScene(scene)
        skview.ignoresSiblingOrder = true
        skview.showsFPS = true
        skview.showsNodeCount = true
    }
    
    private func setupGestureRecognizer() {
        self.headGazeRecognizer = UIHeadGazeRecognizer()

        super.virtualCursorView?.smoothness = 4

        super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
        
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
            
//            print("leftOutside: \(isOutsideLeft) rightOutside: \(isOutsideRight) posY: \(localCursorPos.y)")
//            self.xyLabel.text = String.init(format: "(%.2f, %.2f)", localCursorPos.x, localCursorPos.y)
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
    
    private func startRecording() throws {
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                let newResult: String = result.bestTranscription.formattedString
                
                var command = ""
                
                if self.oldResult == "" {
                    self.oldResult = newResult.lowercased()
                    command = self.oldResult
                }else{
                    let diff = newResult.lowercased().replacingOccurrences(of:self.oldResult.lowercased(),with:"")
                    self.oldResult = newResult.lowercased()
                    
                    command = diff.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if command == ""{
                    print("Command is Empty")
                }else{
                    print("Command \(command)")
                    
                    if command == "left"{
                        self.voiceControlDeleget!.shiftLeft()
                    }
                    
                    if command == "right"{
                        self.voiceControlDeleget!.shiftRight()
                    }
                    
                    if command == "up"{
                        self.voiceControlDeleget!.shiftUp()
                    }
                    
                    if command == "down"{
                        self.voiceControlDeleget!.shiftDown()
                    }
                }
                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        print("(Go ahead, I'm listening)")
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    @IBAction func test(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
                try startRecording()
                recordButton.setTitle("Stop Recording", for: [])
            } catch {
                recordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }
}
