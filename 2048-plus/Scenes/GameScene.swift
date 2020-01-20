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
    var nodes: [Position:SKSpriteNode] = [:]
    var touchInputManger: TouchInputManger? = nil
    
    override func didMove(to: SKView) {
        touchInputManger = TouchInputManger.init(view: self.view!, controlDeleget: self)
        fillTiles()
        createGrid()
        createScoreLabelNode()
        generateTile(extactPosition: Position(0,0))
        generateTile(extactPosition: Position(0,3))
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
    
    func moveNode(oldPosition: Position,newPosition: Position, node: SKSpriteNode, merge: Bool) -> Bool{
        if oldPosition == newPosition{ // the node is already on the boundery
            return false
        }
        if (!merge){
            guard let coordinate = grid?.gridPosition(row: newPosition.x, col: newPosition.y) else {
                return false
            }
            node.run(SKAction.move(to: coordinate, duration: DURATION))
            self.nodes.removeValue(forKey: oldPosition)
            self.nodes[newPosition] = node
            return true
        }else{
            let bigNode = self.nodes[newPosition]
            
            if bigNode == nil{
                print("oldPosition \(oldPosition)")
                print("newPosition \(newPosition)")
                return false
            }
            
            node.run(SKAction.move(to: bigNode!.position, duration: DURATION))
            self.nodes.removeValue(forKey: oldPosition)
            node.removeFromParent()
            
            let label = bigNode?.childNode(withName: "Label") as! SKLabelNode
            let newValue = tiles[getKey(position: newPosition)]?.value
            label.text = "\(newValue!)"
            label.fontColor = Colors.tileText(value: newValue).color
            bigNode?.color = Colors.tile(value: newValue).color
            bigNode?.run(SKAction.sequence([SKAction.scale(to: 1.3, duration: DURATION * 1.5),
                                           SKAction.scale(to: 1, duration: DURATION * 1.5)]))
            updateScore(score: newValue!)
            return true
        }
    }
    
    func handleShift(direction: MoveDirection){
        var sortedNodes:[(Position,SKSpriteNode)]? = nil
        switch direction {
            case MoveDirection.down:
                sortedNodes = nodes.sorted{ $0.key.x > $1.key.x}
            case MoveDirection.up:
                sortedNodes = nodes.sorted{ $0.key.x < $1.key.x}
            case MoveDirection.right:
                sortedNodes = nodes.sorted{ $0.key.y > $1.key.y}
            case MoveDirection.left:
                sortedNodes = nodes.sorted{ $0.key.y < $1.key.y}
        }
        var oneNodeMoved = false
        
        for (position, node) in sortedNodes!{
            let (newPosition,merge) = nextPositionV2(oldPosition: position, direction: direction)
            let nodeHasMoved = moveNode(oldPosition: position,newPosition: newPosition, node: node, merge:merge)
            if nodeHasMoved{
                oneNodeMoved = true
            }
        }
        if oneNodeMoved{
            generateTile(extactPosition: nil)
        }else{
            failedShiftingAnimation(to: direction)
        }
    }
        
    func nextPositionV2(oldPosition:Position, direction:MoveDirection) -> (Position,Bool) {
        var newX:Int = oldPosition.x
        var newY:Int = oldPosition.y
        
        var merge = false
        
        let valueToMove = tiles[getKey(position: oldPosition)]?.value
    
        if (direction == MoveDirection.up){
            while(newX >= 1 && tiles[getKey(position: Position(newX - 1,newY))]?.value == nil){
                newX = newX - 1
            }
            let newPositionValue = tiles[getKey(position: Position(newX - 1,newY))]?.value
            if (valueToMove == newPositionValue){
                newX = newX - 1
                tiles[getKey(position: Position(newX,newY))]?.value = newPositionValue! * 2
                tiles[getKey(position: oldPosition)]?.value = nil
                merge = true
            }else{
                tiles[getKey(position: oldPosition)]?.value = nil
                tiles[getKey(position: Position(newX,newY))]?.value = valueToMove
            }
        }
        
        if (direction == MoveDirection.down){
            while(newX < SIZE - 1 && tiles[getKey(position: Position(newX + 1,newY))]?.value == nil){
                newX = newX + 1
            }
            let newPositionValue = tiles[getKey(position: Position(newX + 1,newY))]?.value
            if (valueToMove == newPositionValue){
                newX = newX + 1
                tiles[getKey(position: Position(newX,newY))]?.value = newPositionValue! * 2
                tiles[getKey(position: oldPosition)]?.value = nil
                merge = true
            }else{
                tiles[getKey(position: oldPosition)]?.value = nil
                tiles[getKey(position: Position(newX,newY))]?.value = valueToMove
            }
        }
        
        if (direction == MoveDirection.right){
            while(newY < SIZE - 1 && tiles[getKey(position: Position(newX,newY + 1))]?.value == nil){
                newY = newY + 1
            }
            let newPositionValue = tiles[getKey(position: Position(newX,newY + 1))]?.value
            if (valueToMove == newPositionValue){
                newY = newY + 1
                tiles[getKey(position: Position(newX,newY))]?.value = newPositionValue! * 2
                tiles[getKey(position: oldPosition)]?.value = nil
                merge = true
            }else{
                tiles[getKey(position: oldPosition)]?.value = nil
                tiles[getKey(position: Position(newX,newY))]?.value = valueToMove
            }
        }
        
        if (direction == MoveDirection.left){
            while(newY >= 1 && tiles[getKey(position: Position(newX,newY - 1))]?.value == nil){
                newY = newY - 1
            }
            let newPositionValue = tiles[getKey(position: Position(newX,newY - 1))]?.value
            if (valueToMove == newPositionValue){
                newY = newY - 1
                tiles[getKey(position: Position(newX,newY))]?.value = newPositionValue! * 2
                tiles[getKey(position: oldPosition)]?.value = nil
                merge = true
            }else{
                tiles[getKey(position: oldPosition)]?.value = nil
                tiles[getKey(position: Position(newX,newY))]?.value = valueToMove
            }
        }
        
        return (Position(newX, newY), merge)
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
    
    func generateTile(extactPosition: Position?){
        var tilePosition:Position? = nil
        if extactPosition == nil{
            tilePosition = randomPosition()
        }else{
            tilePosition = extactPosition
        }
        if let position = tilePosition{
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
            nodes[position] = block
            
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
        let margin = self.size.height * 0.1
        let size   = self.size.width * 0.20
        let rect = CGRect(x: 0, y: 0, width: size * 2, height: size)
        let tile = SKShapeNode(rect: rect, cornerRadius: 13)
        tile.fillColor = UIColor.orange
        tile.strokeColor = UIColor.white
        tile.lineWidth = 4
        tile.position = CGPoint (x: self.frame.midX - rect.width/2, y: self.size.height - rect.height - margin)
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
        for node in nodes.values {
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
