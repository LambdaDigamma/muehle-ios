//
//  Coordinate.swift
//  Mühle
//
//  Created by Lennart Fischer on 03.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class Coordinate: Equatable, CustomStringConvertible, Hashable {

    var col: Int
    var row: Int
    
    var number: Int {
        
        return row
        
    }
    
    var letter: Character {
        
        switch col {
        case 1: return "A"
        case 2: return "B"
        case 3: return "C"
        case 4: return "D"
        case 5: return "E"
        case 6: return "F"
        case 7: return "G"
        default: return "*"
        }
        
    }
    
    init(col: Int, row: Int) {
        
        self.row = row
        self.col = col
        
    }
    
    init(number: Int, letter: Character) {
        
        self.row = number
        self.col = Coordinate.column(from: letter)
        
    }
    
    class func column(from letter: Character) -> Int {
        
        switch letter {
        case "A": return 1
        case "B": return 2
        case "C": return 3
        case "D": return 4
        case "E": return 5
        case "F": return 6
        case "G": return 7
        default: return -1
        }
        
    }
    
    public var description: String {
        
        return "Coordinate: (\(col)|\(row))"
        
    }
    
    var hashValue: Int {
        
        return (31 &* col.hashValue) &+ row.hashValue
        
    }
    
}

func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.col == rhs.col && rhs.row == lhs.row
}
