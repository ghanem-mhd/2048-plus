//
//  GameScene.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 29.12.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to: SKView) {
        let number = CGFloat(3.0)
        let size = CGFloat(frame.size.width/number - 10)
        if let grid = Grid(blockSize: size, rows:Int(number), cols:Int(number)) {
            grid.position = CGPoint (x:frame.midX, y:frame.midY)
            addChild(grid)

            
            let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.text = "2"
            scoreLabel.fontSize = 30
            scoreLabel.fontColor = Colors.tile(value: 2).color
            scoreLabel.position = grid.gridPosition(row: 1, col: 0)
            addChild(scoreLabel)
        }
    }
}

