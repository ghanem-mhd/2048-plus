//
//  Tile.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 02.01.20.
//  Copyright © 2020 Mohammed Ghannm. All rights reserved.
//

import Foundation
import SpriteKit

struct Tile: Equatable,Hashable{
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.position == rhs.position
    }
    
    let position: Position
    var value: Int?

    init(position: Position, value: Int? = nil) {
        self.position = position
        self.value = value
    }
    
    func ToString() -> String {
        return "(\(String(describing: value)), \(position.x), \(position.y))"
    }
}

