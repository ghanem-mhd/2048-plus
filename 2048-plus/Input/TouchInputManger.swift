//
//  TouchInputManger.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 03.01.20.
//  Copyright © 2020 Mohammed Ghannm. All rights reserved.
//

import Foundation
import UIKit

class TouchInputManger{
    
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    
    var view: UIView
    var controlDeleget: GameScenceControlDelegate
    
    init (view: UIView, controlDeleget:GameScenceControlDelegate){
        self.view = view
        self.controlDeleget = controlDeleget
        setUpGestureRecognizers()
    }
    
    private func setUpGestureRecognizers(){
        swipeRightRec.addTarget(self, action: #selector(self.swipedRight) )
        swipeRightRec.direction = .right
        self.view.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(self.swipedLeft) )
        swipeLeftRec.direction = .left
        self.view.addGestureRecognizer(swipeLeftRec)
        
        
        swipeUpRec.addTarget(self, action: #selector(self.swipedUp) )
        swipeUpRec.direction = .up
        self.view.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(self.swipedDown) )
        swipeDownRec.direction = .down
        self.view.addGestureRecognizer(swipeDownRec)
    }
    
    @objc func swipedRight(sender:UISwipeGestureRecognizer){
        print("Right")
        controlDeleget.shiftRight()
    }
    
    @objc func swipedLeft(sender:UISwipeGestureRecognizer) {
        print("Left")
        controlDeleget.shiftLeft()
    }
    
    @objc func swipedUp(sender:UISwipeGestureRecognizer) {
        print("Up")
        controlDeleget.shiftUp()
    }
    
    @objc func swipedDown(sender:UISwipeGestureRecognizer) {
        print("Down")
        controlDeleget.shiftDown()
    }
}
