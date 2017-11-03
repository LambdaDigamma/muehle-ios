//
//  Turn.swift
//  Mühle
//
//  Created by Lennart Fischer on 03.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class Turn: CustomStringConvertible, Copying {
    
    var player: Player
    var originCoordinate: Coordinate
    var destinationCoordinate: Coordinate
    
    init(player: Player, originCoordinate: Coordinate, destinationCoordinate: Coordinate) {
        
        self.player = player
        self.originCoordinate = originCoordinate
        self.destinationCoordinate = destinationCoordinate
        
    }
    
    required init(original: Turn) {
        
        player = original.player
        originCoordinate = original.originCoordinate
        destinationCoordinate = original.destinationCoordinate
        
    }
    
    public var description: String {
        
        return "Turn: \(self.player.rawValue) from \(originCoordinate) to \(destinationCoordinate)"
        
    }
    
}
