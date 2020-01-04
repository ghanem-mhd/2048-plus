//
//  Position.swift
//  2048-plus
//
//  Created by Mohammed Ghannm on 02.01.20.
//  Copyright © 2020 Mohammed Ghannm. All rights reserved.
//

import Foundation

struct Position: Equatable,Hashable {
    static func ==(lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    var x, y: Int
    init(_ x: Int, _ y: Int) {
        (self.x, self.y) = (x, y)
    }

    func ToString() -> String {
        return "(\(x), \(y))"
    }
}
