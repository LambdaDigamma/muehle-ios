//
//  MiniMaxAI.swift
//  Muehle
//
//  Created by Lennart Fischer on 28.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class MiniMaxAI: AI {
    
    weak var game: Game!
    
    var aiPlayer = GameConfig.aiPlayer
    
    init(game: Game) {
        
        self.game = game
        
    }
    
    func determineTile() -> Coordinate {
        return Coordinate(col: 0, row: 0)
    }
    
    func determineTurn() -> Turn {
        
        return Turn(player: .a, originCoordinate: Coordinate(col: 0, row: 0), destinationCoordinate: Coordinate(col: 0, row: 0))
        
    }
    
    func determineJumpTurn() -> Turn {
        return Turn(player: .a, originCoordinate: Coordinate(col: 0, row: 0), destinationCoordinate: Coordinate(col: 0, row: 0))
    }
    
    func determineRemovingCoordinate() -> Coordinate {
        return Coordinate(col: 0, row: 0)
    }
    
}
