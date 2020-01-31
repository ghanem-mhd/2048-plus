//
//  GameViewController.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 29.12.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Speech


class GameViewController: UIViewController, ARSessionDelegate {
    
    /** Head Tracking Helper Variables */
    
    // use "deltaDelay" frames to collect Head Data before processing Data
    private var deltaDelay = 20
    private var deltaDelayCount = 0
    
    // saving last head move state
    private var lastMove = ""
    
    // forget last move after lastMoveDelay process cycles
    private var lastMoveDelay = 4
    private var noMoveCount = 0
    
    // helper variables saving head position deltas
    private var xHeadDelta: Float = 0.0
    private var xHeadLast: Float = 0.0
    private var yHeadLast: Float = 0.0
    private var yHeadDelta: Float = 0.0
    
    var currentFaceAnchor: ARFaceAnchor?
    var voiceControlDeleget: GameSceneControlDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skview = self.view as? ARSKView else{
            return
        }
        let scene = GameScene(size: skview.bounds.size)
        voiceControlDeleget = scene
        
        scene.backgroundColor = .clear
        
        skview.delegate = self
        skview.session.delegate = self
        skview.presentScene(scene)
        skview.ignoresSiblingOrder = true
        skview.showsFPS = true
        skview.showsNodeCount = true
        skview.allowsTransparency = true
    }
    
    func resetTracking() {
        // boilerplate arkit code
        guard let skview = self.view as? ARSKView else{ return }
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        skview.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // AR experiences typically involve moving the device without
        // touch input for some time, so prevent auto screen dimming.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // "Reset" to run the AR session for the first time.
        resetTracking()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // ar error catching
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
}

extension GameViewController: ARSKViewDelegate {
    
    /// - Tag: ARFaceGeometryUpdate
    func view(_ renderer: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        currentFaceAnchor = faceAnchor
        
        // get relevant vector from head matrix
        let xHead = currentFaceAnchor!.transform[2, 0]
        let yHead = currentFaceAnchor!.transform[1, 2]
        
        deltaDelayCount += 1
        if (deltaDelayCount < deltaDelay) {
            // collect data before processing it
            xHeadDelta += (xHead - xHeadLast)
            yHeadDelta += (yHead - yHeadLast)
            xHeadLast = xHead
            yHeadLast = yHead
            return
        }
        
        // calculate head x and y delta over the last "deltaDelayCount" frames
        let roundedYDelta = Double(round(1000*yHeadDelta)/1000)
        let roundedXDelta = Double(round(1000*xHeadDelta)/1000)
        
        // process moves if certain threshold has been reached
        if roundedXDelta < -0.1 {
            // left
            print("left")
            if lastMove == "right" {
                self.voiceControlDeleget!.shiftRight()
                lastMove = ""
                print("shiftRight")
            } else {
                lastMove = "left"
            }
        } else if roundedXDelta > 0.1 {
            // right
            print("right")
            if lastMove == "left" {
                self.voiceControlDeleget!.shiftLeft()
                print("shiftLeft")
                lastMove = ""
            } else {
                lastMove = "right"
            }
        } else if roundedYDelta < -0.1 {
            // up
            print("up")
            if lastMove == "down" {
                self.voiceControlDeleget!.shiftDown()
                print("shiftDown")
                lastMove = ""
            } else {
                lastMove = "up"
            }
        } else if roundedYDelta > 0.1 {
            // down
            print("down")
            if lastMove == "up" {
                self.voiceControlDeleget!.shiftUp()
                print("shiftUp")
                lastMove = ""
            } else {
                lastMove = "down"
            }
        } else {
            // in case the head did not move enough, we are counting how many frames the head did not move. After "noMoveCount" process cycles the last movement will decay
            noMoveCount += 1
            if lastMoveDelay <= noMoveCount {
                lastMove = ""
                noMoveCount = 0
            }
        }
        
        // reset the helper variables
        deltaDelayCount = 0
        xHeadDelta = 0
        yHeadDelta = 0
    }
}
