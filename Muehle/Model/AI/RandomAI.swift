//
//  RandomAI.swift
//  Muehle
//
//  Created by Lennart Fischer on 21.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class RandomAI: AI {
    
    weak var game: Game!
    
    var aiPlayer = Player.b
    
    init(game: Game) {
        
        self.game = game
        
    }
    
    func determineTile() -> Coordinate {
        
        var notOccupiedCoordinates: [Coordinate] = []
        
        notOccupiedCoordinates = game.allCoordinates()
        
        for tile in game.tiles {
            
            notOccupiedCoordinates = notOccupiedCoordinates.filter { $0 != tile.coordinate }
            
        }
        
        let random = Int(arc4random_uniform(UInt32(notOccupiedCoordinates.count)))
        
        return notOccupiedCoordinates[random]
        
    }
    
    func determineTurn() -> Turn {
        
        var allPossibleTurns: [Turn] = []
        
        for tile in game.tiles.filter({ $0.player == aiPlayer }) {
            
            for destination in game.allowedTurns(from: tile.coordinate) {
                
                allPossibleTurns.append(Turn(player: aiPlayer, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                
            }
            
        }
        
        let index = allPossibleTurns.count.random()
        
        return allPossibleTurns[index]
        
    }
    
    func determineRemovingCoordinate() -> Coordinate {
        
        let opponentPlayer: Player
        
        if aiPlayer == .b {
            opponentPlayer = .a
        } else {
            opponentPlayer = .b
        }
        
        let tiles = game.tiles.filter({ $0.player == opponentPlayer && !game.isInMorris(coordinate: $0.coordinate) })
        
        let index = tiles.count.random()
        
        return tiles[index].coordinate
        
    }
    
}
