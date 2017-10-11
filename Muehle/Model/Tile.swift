//
//  Tile.swift
//  Mühle
//
//  Created by Lennart Fischer on 03.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class Tile {
    
    var coordinate: Coordinate
    var player: Player
    
    init(coordinate: Coordinate, player: Player) {
        
        self.coordinate = coordinate
        self.player = player
        
    }

}
