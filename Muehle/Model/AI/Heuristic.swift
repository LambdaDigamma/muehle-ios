//
//  Heuristic.swift
//  Muehle
//
//  Created by Lennart Fischer on 29.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

protocol Heuristic: Decideable {}

extension Heuristic {
    
    func numberOfClosedMorris(game: Game, player: Player) -> Int {
        
        var numberOfMorris = 0
        
        for morris in Morris.all {
            
            if game.isTile(of: player, at: morris.firstCoordinate) && game.isTile(of: player, at: morris.secondCoordinate) && game.isTile(of: player, at: morris.thirdCoordinate) {
                
                numberOfMorris += 1
                
            }
            
        }
        
        return numberOfMorris
        
    }
    
    func numberOfOpenMorris(game: Game, player: Player) -> Int {
        
        var numberOfOpenMorris = 0
        
        for morris in Morris.all {
            
            if isOpenMorris(player: player, coordinates: [morris.firstCoordinate, morris.secondCoordinate, morris.thirdCoordinate], game: game) {
                
                numberOfOpenMorris += 1
                
            }
            
        }
        
        return numberOfOpenMorris
        
    }
    
    func isOpenMorris(player: Player, coordinates: [Coordinate], game: Game) -> Bool {
        
        var numberOfColor = 0
        var numberOfEmpty = 0
        
        for coordinate in coordinates {
            
            if game.isTile(of: player, at: coordinate) {
                
                numberOfColor += 1
                
            } else {
                
                numberOfEmpty += 1
                
            }
            
        }
        
        return numberOfColor == 2 && numberOfEmpty == 1
        
    }
    
}
