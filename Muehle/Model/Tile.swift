//
//  Tile.swift
//  Mühle
//
//  Created by Lennart Fischer on 03.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

class Tile: Equatable {
    
    var coordinate: Coordinate
    var player: Player
    
    init(coordinate: Coordinate, player: Player) {
        
        self.coordinate = coordinate
        self.player = player
        
    }
    
}

func ==(lhs: Tile, rhs: Tile) -> Bool {
    
    return lhs.coordinate == rhs.coordinate && lhs.player == rhs.player
    
}
