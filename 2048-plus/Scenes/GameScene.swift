//
//  GameScene.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 29.12.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import SpriteKit
import CoreGraphics

class GameScene: SKScene, GameScenceControlDelegate {

    let SIZE = 4, DURATION = 0.08
    
    var currentScore = 0
    
    var grid:Grid? = nil
    var scoreLabel:SKLabelNode? = nil
    var tiles: [String:Tile] = [:]
    var nodes: [SKSpriteNode:Position] = [:]
    var touchInputManger: TouchInputManger? = nil
    
    override func didMove(to: SKView) {
        touchInputManger = TouchInputManger.init(view: self.view!, controlDeleget: self)
        fillTiles()
        createGrid()
        createScoreLabelNode()
        generateTile()
    }
    
    func createGrid(){
        let size = CGFloat(frame.size.width / CGFloat(SIZE) - 10)
        grid = Grid(blockSize: size, rows:SIZE, cols:SIZE)
        grid?.position = CGPoint (x:frame.midX, y:frame.midY)
        addChild(grid!)
    }
    
    func fillTiles(){
        for row in 0...SIZE-1{
            for column in 0...SIZE-1{
                let pos =  Position(row, column)
                let tile = Tile(position:pos)
                tiles[getKey(position: pos)] = tile
            }
        }
    }
    
    func getNodeAtPosition(position:Position) -> SKSpriteNode?{
        for (node, nodePosition) in nodes{
            if position == nodePosition{
                return node
            }
        }
        return nil
    }
    
    func moveNode(oldPosition: Position,newPosition: Position, node: SKSpriteNode) -> Bool{
        if oldPosition == newPosition{ // the node is already on the boundery
            return false
        }
        if tiles[getKey(position: oldPosition)]?.value  == tiles[getKey(position: newPosition)]?.value{
            let bigNode = getNodeAtPosition(position: newPosition)
            node.run(SKAction.move(to: bigNode!.position, duration: DURATION),completion: {
                self.nodes.removeValue(forKey: node)
                node.removeFromParent()

            })
            guard let oldValue = tiles[getKey(position: newPosition)]?.value else {
                return false
            }
            let newValue = oldValue + oldValue
            tiles[getKey(position: newPosition)]?.value = newValue
            tiles[getKey(position: oldPosition)]?.value = nil
            let label = bigNode?.childNode(withName: "Label") as! SKLabelNode
            label.text = String(newValue)
            label.fontColor = Colors.tileText(value: newValue).color
            bigNode?.color = Colors.tile(value: newValue).color
            bigNode?.run(SKAction.sequence([SKAction.scale(to: 1.3, duration: DURATION * 1.5), SKAction.scale(to: 1, duration: DURATION * 1.5)]))

            updateScore(score: newValue)
            return true
        }else{
            if tiles[getKey(position: newPosition)]?.value != nil{
                return false
            }
            guard let coordinate = grid?.gridPosition(row: newPosition.x, col: newPosition.y) else {
                return false
            }
            let oldValue = tiles[getKey(position: oldPosition)]?.value
            tiles[getKey(position: newPosition)]?.value = oldValue
            tiles[getKey(position: oldPosition)]?.value = nil
            node.run(SKAction.move(to: coordinate, duration: DURATION), completion: {
                self.nodes[node] = newPosition
            })
             return true
        }
    }
    
    func handleShift(direction: MoveDirection){
        var oneNodeMoved = false
        for (node, position) in nodes{
            let newPosition = nextPosition(position: position, direction: direction)
            let nodeHasMoved = moveNode(oldPosition: position,newPosition: newPosition, node: node)
            if nodeHasMoved{
                oneNodeMoved = true
            }
        }
        if oneNodeMoved{
            generateTile()
        }else{
            failedShiftingAnimation(to: direction)
        }
    }
    
    func randomPosition() -> Position? {
        let tilesArray = Array(tiles.values)
        let emptyTiles = tilesArray.filter({$0.value == nil})
        if emptyTiles.count == 0 {
            print("GameOver")
            return nil
        }else{
            return emptyTiles[Int(arc4random_uniform(UInt32(emptyTiles.count)))].position
        }
    }
    
    func nextPosition(position:Position, direction:MoveDirection) -> Position {
        var newX:Int = position.x
        var newY:Int = position.y
        
        switch direction {
            case MoveDirection.down:
                newX = position.x + 1
                newY = position.y
            case MoveDirection.up:
                newX = position.x - 1
                newY = position.y
            case MoveDirection.right:
                newX = position.x
                newY = position.y + 1
            case MoveDirection.left:
                newX = position.x
                newY = position.y - 1
        }
        if newX < 0 {
            newX = 0
        }
        if newX >= SIZE{
            newX = SIZE - 1
        }
        if newY < 0 {
            newY = 0
        }
        if newY >= SIZE{
            newY = SIZE - 1
        }
        return Position(newX, newY)
    }
    
    
    func generateTile(){
        if let position = randomPosition(){
            let size = CGFloat(frame.size.width / CGFloat(SIZE)  - 20)
            
            let block = SKSpriteNode(color: Colors.tile(value: 2).color, size: CGSize(width: size, height: size))
            block.alpha = 0
            block.position = grid!.gridPosition(row: position.x, col: position.y)
            grid?.addChild(block)
            
            let label = SKLabelNode()
            label.name = "Label"
            label.fontName = "AvenirNext-Bold"
            label.text = "2"
            label.fontSize = 30
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.fontColor = Colors.tileText(value: 2).color
            
            block.addChild(label)
            
            tiles[getKey(position: position)]?.value = 2
            nodes[block] = position
            
            block.run(SKAction.fadeIn(withDuration: DURATION * 3))
        }
    }
    
    func getKey(position: Position) -> String{
        return "\(position.x),\(position.y)"
    }
    
    func shiftUp() {
        handleShift(direction: MoveDirection.up)
    }
    
    func shiftDown() {
        handleShift(direction: MoveDirection.down)
    }
    
    func shiftRight() {
        handleShift(direction: MoveDirection.right)
    }
    
    func shiftLeft() {
        handleShift(direction: MoveDirection.left)
    }
    
    enum MoveDirection {
        case up
        case down
        case left
        case right
    }
    
    func createScoreLabelNode(){
        let margin = self.size.width * 0.04
        let size   = self.size.width * 0.20
        let rect = CGRect(x: 0, y: 0, width: size * 1.6, height: size)
        let tile = SKShapeNode(rect: rect, cornerRadius: 13)
        tile.fillColor = UIColor.orange
        tile.strokeColor = UIColor.white
        tile.lineWidth = 4
        tile.position = CGPoint (x: (margin - margin * 0.15), y: self.size.height - rect.height - margin)
        addChild(tile)
        
        scoreLabel = SKLabelNode()
        scoreLabel?.name = "score"
        scoreLabel?.fontName = "AvenirNext-Bold"
        scoreLabel?.text = "Score: \(currentScore)"
        scoreLabel?.fontSize = 20
        scoreLabel?.horizontalAlignmentMode = .center
        scoreLabel?.verticalAlignmentMode = .center
        scoreLabel?.fontColor = UIColor.white
        scoreLabel?.position = CGPoint(x: rect.width/2, y: rect.height/2)
        tile.addChild(scoreLabel!)
    }
    
    func updateScore(score: Int){
        currentScore = currentScore + score
        scoreLabel?.text = "Score: \(currentScore)"
    }
    
    
    func failedShiftingAnimation(to direction: MoveDirection) {
        let delta: CGFloat = 30
        var deltaPoint: CGPoint {
            switch direction {
            case .down:
                return CGPoint(x: 0, y: -delta)
            case .up:
                return CGPoint(x: 0, y: delta)
            case .left:
                return CGPoint(x: -delta, y: 0)
            case .right:
                return CGPoint(x: delta, y: 0)
            }
        }
        for node in nodes.keys {
            let move        = SKAction.move(to: node.position + deltaPoint, duration: DURATION)
            let moveBack    = SKAction.move(to: node.position, duration: DURATION)
            node.run(SKAction.sequence([move,moveBack]))
        }
    }
}


public extension CGPoint{
    static func +(left: CGPoint, right: CGPoint) -> CGPoint{
        return CGPoint(x: left.x + right.x, y:left.y + right.y)
    }
    
    static func -(left: CGPoint, right: CGPoint) -> CGPoint{
        return CGPoint(x: left.x - right.x, y:left.y - right.y)
    }
}
