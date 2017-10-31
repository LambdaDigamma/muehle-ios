//
//  RandomAI.swift
//  Muehle
//
//  Created by Lennart Fischer on 21.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

let SharedRandomAI = RandomAI()

class RandomAI: Calculateable {
    
    weak var game: Game!
    
    var aiPlayer = GameConfig.aiPlayer
    
    fileprivate init() {
        
    }
    
    func calculateNextMove(game: Game) -> AIMove {
        
        var chosenMove: AIMove!
        
        var ac = action(for: GameConfig.aiPlayer, game: game)
        
        if game.state == .insert {
            
            let coordiante = determineTile(game: game)
            
            chosenMove = AIMove(action: .set, coordinate: coordiante)
            
        } else if game.state == .move {
            
//            let coordinate = determine
            
        }
        
        return chosenMove
    }
    
    func determineTile(game: Game) -> Coordinate {
        
        var notOccupiedCoordinates: [Coordinate] = []
        
        notOccupiedCoordinates = game.allCoordinates()
        
        for tile in game.tiles {
            
            notOccupiedCoordinates = notOccupiedCoordinates.filter { $0 != tile.coordinate }
            
        }
        
        let random = Int(arc4random_uniform(UInt32(notOccupiedCoordinates.count)))
        
        return notOccupiedCoordinates[random]
        
    }
    
    func determineTurn(game: Game) -> Turn {
        
        var allPossibleTurns: [Turn] = []
        
        for tile in game.tiles.filter({ $0.player == aiPlayer }) {
            
            for destination in game.allowedTurns(from: tile.coordinate) {
                
                if !game.isOccupied(destination) {
                    
                    allPossibleTurns.append(Turn(player: aiPlayer, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                    
                }
                
            }
            
        }
        
        let index = allPossibleTurns.count.random()
        
        return allPossibleTurns[index]
        
    }
    
    func determineJumpTurn(game: Game) -> Turn {
        
        var allPossibleTurns: [Turn] = []
        
        for tile in game.tiles.filter({ $0.player == aiPlayer }) {
            
            for destination in game.allCoordinates().filter({ !game.isOccupied($0) && tile.coordinate != $0 }) {
                
                allPossibleTurns.append(Turn(player: aiPlayer, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                
            }
            
        }
        
        let index = allPossibleTurns.count.random()
        
        return allPossibleTurns[index]
        
    }
    
    func determineRemovingCoordinate(game: Game) -> Coordinate {
        
        let opponentPlayer = Player.opponent(of: aiPlayer)
        
        let tiles = game.tiles.filter({ $0.player == opponentPlayer && !game.isInMorris(coordinate: $0.coordinate) })
        
        let index = tiles.count.random()
        
        return tiles[index].coordinate
        
    }
    
    private func action(for player: Player, game: Game) -> Action {
        
        if let removingPlayer = game.playerCanRemove {
            
            if removingPlayer == player {
                
                return .remove
                
            }
            
        }
        
        if game.state == .insert {
            
            return .set
            
        } else if game.state == .move {
            
            return .move
            
        } else if game.state == .jump {
            
            if game.playerCanJump(player) {
                
                return .jump
                
            } else {
                
                return .move
                
            }
            
        }
        
        return .set
        
    }
    
}
