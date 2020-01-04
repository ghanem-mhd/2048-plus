//
//  GameScene.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 29.12.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import SpriteKit
import Speech

class GameScene: SKScene, GameScenceControlDelegate, SFSpeechRecognizerDelegate {

    let SIZE = 3, DURATION = 0.08
    
    var grid:Grid? = nil
    var tiles: [String:Tile] = [:]
    var nodes: [SKSpriteNode:Position] = [:]
    var touchInputManger: TouchInputManger? = nil
    
    override func didMove(to: SKView) {
        touchInputManger = TouchInputManger.init(view: self.view!, controlDeleget: self)
        fillTiles()
        createGrid()
        generateTile()
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
    
    func moveNode(oldPosition: Position,newPosition: Position, node: SKSpriteNode){
        if oldPosition == newPosition{ // the node is already on the boundery
            return
        }
        if tiles[getKey(position: oldPosition)]?.value  == tiles[getKey(position: newPosition)]?.value{
            node.removeFromParent()
            nodes.removeValue(forKey: node)
            
            let bigNode = getNodeAtPosition(position: newPosition)
            guard let oldValue = tiles[getKey(position: newPosition)]?.value else {
                return
            }
    
            let newValue = oldValue + oldValue
            tiles[getKey(position: newPosition)]?.value = newValue
            tiles[getKey(position: oldPosition)]?.value = nil
            let label = bigNode?.childNode(withName: "Label") as! SKLabelNode
            label.text = String(newValue)
            bigNode?.color = Colors.tile(value: newValue).color
            
        }else{
            if tiles[getKey(position: newPosition)]?.value != nil{
                return
            }
            guard let coordinate = grid?.gridPosition(row: newPosition.x, col: newPosition.y) else {
                return
            }
            let oldValue = tiles[getKey(position: oldPosition)]?.value
            tiles[getKey(position: newPosition)]?.value = oldValue
            tiles[getKey(position: oldPosition)]?.value = nil
            node.run(SKAction.move(to: coordinate, duration: DURATION), completion: {
                self.nodes[node] = newPosition
            })
        }
    }
    
    func handleShift(direction: MoveDirection){
        for (node, position) in nodes{
            let newPosition = nextPosition(position: position, direction: direction)
            moveNode(oldPosition: position,newPosition: newPosition, node: node)
        }
        generateTile()
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
        var newX:Int = 0
        var newY:Int = 0
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
            block.position = grid!.gridPosition(row: position.x, col: position.y)
            grid?.addChild(block)
            
            let label = SKLabelNode()
            label.name = "Label"
            label.fontName = "AvenirNext-Bold"
            label.text = "2"
            label.fontSize = 50
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.fontColor = UIColor.black
            block.addChild(label)
            
            tiles[getKey(position: position)]?.value = 2
            nodes[block] = position
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
}
