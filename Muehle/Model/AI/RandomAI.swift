//
//  RandomAI.swift
//  Muehle
//
//  Created by Lennart Fischer on 21.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class RandomAI: AI {
    
    weak var game: Game?
    
    init(game: Game) {
        
        
        
    }
    
    func registerEnemyTile(_ tile: Tile) {
        
    }
    
    func registerEnemyTurn(_ turn: Turn) {
        
    }
    
    func determineTile() -> Coordinate {
        
        return Coordinate(col: 0, row: 0)
        
    }
    
}
