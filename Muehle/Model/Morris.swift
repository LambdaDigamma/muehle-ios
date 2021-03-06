//
//  Morris.swift
//  Muehle
//
//  Created by Lennart Fischer on 11.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class Morris: Equatable, CustomStringConvertible, Copying {
    
    var firstCoordinate: Coordinate
    var secondCoordinate: Coordinate
    var thirdCoordinate: Coordinate
    
    var player: Player? = nil
    
    private static let morrises: [[Coordinate]] = [
        [Coordinate(col: 1, row: 4), Coordinate(col: 1, row: 1), Coordinate(col: 1, row: 7)], // Outer Morris
        [Coordinate(col: 4, row: 1), Coordinate(col: 1, row: 1), Coordinate(col: 7, row: 1)],
        [Coordinate(col: 7, row: 4), Coordinate(col: 7, row: 1), Coordinate(col: 7, row: 7)],
        [Coordinate(col: 4, row: 7), Coordinate(col: 1, row: 7), Coordinate(col: 7, row: 7)],
        [Coordinate(col: 2, row: 2), Coordinate(col: 4, row: 2), Coordinate(col: 6, row: 2)], // Middle Morris
        [Coordinate(col: 6, row: 2), Coordinate(col: 6, row: 4), Coordinate(col: 6, row: 6)],
        [Coordinate(col: 6, row: 6), Coordinate(col: 4, row: 6), Coordinate(col: 2, row: 6)],
        [Coordinate(col: 2, row: 6), Coordinate(col: 2, row: 4), Coordinate(col: 2, row: 2)],
        [Coordinate(col: 3, row: 3), Coordinate(col: 4, row: 3), Coordinate(col: 5, row: 3)], // Inner Morris
        [Coordinate(col: 5, row: 3), Coordinate(col: 5, row: 4), Coordinate(col: 5, row: 5)],
        [Coordinate(col: 5, row: 5), Coordinate(col: 4, row: 5), Coordinate(col: 3, row: 5)],
        [Coordinate(col: 3, row: 5), Coordinate(col: 3, row: 4), Coordinate(col: 3, row: 3)],
        [Coordinate(col: 1, row: 4), Coordinate(col: 2, row: 4), Coordinate(col: 3, row: 4)], // Other Morris
        [Coordinate(col: 4, row: 1), Coordinate(col: 4, row: 2), Coordinate(col: 4, row: 3)],
        [Coordinate(col: 7, row: 4), Coordinate(col: 6, row: 4), Coordinate(col: 5, row: 4)],
        [Coordinate(col: 4, row: 7), Coordinate(col: 4, row: 6), Coordinate(col: 4, row: 5)]]
    
    init(coordinates: [Coordinate]) {
        
        self.firstCoordinate = coordinates[0]
        self.secondCoordinate = coordinates[1]
        self.thirdCoordinate = coordinates[2]
        
    }
    
    required init(original: Morris) {
        
        firstCoordinate = original.firstCoordinate
        secondCoordinate = original.secondCoordinate
        thirdCoordinate = original.thirdCoordinate
        player = original.player
        
    }
    
    static var all: [Morris] {
        
        var results: [Morris] = []
        
        for morris in Morris.morrises {
            
            let m = Morris(coordinates: morris)
            
            results.append(m)
            
        }
        
        return results
        
    }
    
    public var description: String {
        return "Morris: 1. \(firstCoordinate), 2. \(secondCoordinate), 3. \(thirdCoordinate)"
    }
    

}

func ==(lhs: Morris, rhs: Morris) -> Bool {
    
    return lhs.firstCoordinate == rhs.firstCoordinate && rhs.secondCoordinate == lhs.secondCoordinate && rhs.thirdCoordinate == lhs.thirdCoordinate
    
}
