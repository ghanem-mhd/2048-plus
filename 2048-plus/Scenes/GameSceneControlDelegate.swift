//
//  GameSceneControllerDelegate.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 03.01.20.
//  Copyright © 2020 Mohammed Ghannm. All rights reserved.
//

import Foundation

// delegate to control the game scene
protocol GameSceneControlDelegate {
    func shiftUp()
    func shiftDown()
    func shiftRight()
    func shiftLeft()
}


