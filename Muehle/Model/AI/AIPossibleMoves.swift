//
//  AIPossibleMoves.swift
//  Muehle
//
//  Created by Lennart Fischer on 28.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class AIPossibleMoves {
    
    public var nextAction: Action
    public var activePlayer: Player
    public var toMove: [Coordinate]
    public var fromMove: [Coordinate]
    private var isMorrisClosed: [Bool]
    
    init(game: Game) {
        
        self.toMove = []
        self.fromMove = []
        self.isMorrisClosed = []
        self.activePlayer = game.playerToMove
        self.nextAction = .set
        
        self.nextAction = action(for: activePlayer, game: game)
        
        self.calculatePossibleMoves(for: nextAction, game: game)
        
        let isMoving = nextAction == .move || nextAction == .jump
        
        if nextAction != .remove {
            sortPossibleMoves(isMoving: isMoving)
        }
        
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
    
    private func calculatePossibleMoves(for action: Action, game: Game) {
        
        if action == .set {
            
            for coordinate in unoccupiedCoordinates(game: game) {
                
                toMove.append(coordinate)
                isMorrisClosed.append(closedMill(for: activePlayer, at: coordinate, game: game))
                
            }
            
        } else if action == .move {
            
            let allowedTurns = possibleTurns(for: activePlayer, game: game)
            
            for turn in allowedTurns {
                
                fromMove.append(turn.originCoordinate)
                toMove.append(turn.destinationCoordinate)
                isMorrisClosed.append(closedMill(for: activePlayer, at: turn.originCoordinate, game: game)) // TODO: CHECK TURN ORIGIN COORDINATE
                
            }
            
        } else if action == .jump {
            
            let allowedTurns = possibleJumps(for: activePlayer, game: game)
            
            for turn in allowedTurns {
                
                fromMove.append(turn.originCoordinate)
                toMove.append(turn.destinationCoordinate)
                isMorrisClosed.append(closedMill(for: activePlayer, at: turn.originCoordinate, game: game)) // turn.destinationCoordinate?
                
            }
            
        } else if action == .remove {
            
            let coordinatesOfRemovableTiles = removableTiles(for: activePlayer, game: game)
            
            for coordinate in coordinatesOfRemovableTiles {
                
                toMove.append(coordinate)
                
            }
            
        }
        
    }
    
    private func sortPossibleMoves(isMoving: Bool) {
        
        var sortedTo: [Coordinate] = []
        var sortedFrom: [Coordinate] = []
        
        // Turns That Lead To A Morris
        for (i, isClosed) in isMorrisClosed.enumerated() {
            
            if isClosed {
                
                sortedTo.append(toMove[i])
                
                if isMoving {
                    sortedFrom.append(fromMove[i])
                }
                
            }
            
        }
        
        // Turns That Don't Lead To A Morris
        for (i, isClosed) in isMorrisClosed.enumerated() {
            
            if !isClosed {
                
                sortedTo.append(toMove[i])
                
                if isMoving {
                    sortedFrom.append(fromMove[i])
                }
                
            }
            
        }
        
        self.toMove = sortedTo
        self.fromMove = sortedFrom
        
    }
    
    public func getNumberOfMoves() -> Int {
        return self.toMove.count
    }
    
    private func unoccupiedCoordinates(game: Game) -> [Coordinate] {
        
        var notOccupiedCoordinates: [Coordinate] = []
        
        notOccupiedCoordinates = game.allCoordinates()
        
        for tile in game.tiles {
            
            notOccupiedCoordinates = notOccupiedCoordinates.filter { $0 != tile.coordinate }
            
        }
        
        return notOccupiedCoordinates
        
    }
    
    private func possibleTurns(for player: Player, game: Game) -> [Turn] {
        
        var allPossibleTurns: [Turn] = []
        
        for tile in game.tiles.filter({ $0.player == player }) {
            
            for destination in game.allowedTurns(from: tile.coordinate) {
                
                if !game.isOccupied(destination) {
                    
                    allPossibleTurns.append(Turn(player: player, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                    
                }
                
            }
            
        }
        
        return allPossibleTurns
        
    }
    
    private func possibleJumps(for player: Player, game: Game) -> [Turn] {
        
        var allPossibleTurns: [Turn] = []
        
        for tile in game.tiles.filter({ $0.player == activePlayer }) {
            
            for destination in game.allCoordinates().filter({ !game.isOccupied($0) && tile.coordinate != $0 }) {
                
                allPossibleTurns.append(Turn(player: activePlayer, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                
            }
            
        }
        
        return allPossibleTurns
        
    }
    
    private func removableTiles(for player: Player, game: Game) -> [Coordinate] {
        
        let opponentPlayer = Player.opponent(of: player)
        
        var coordinates: [Coordinate] = []
        
        game.tiles.filter({ $0.player == opponentPlayer && !game.isInMorris(coordinate: $0.coordinate) }).forEach { coordinates.append($0.coordinate) }
        
        return coordinates
        
    }
    
    private func closedMill(for player: Player, at coordinate: Coordinate, game: Game) -> Bool {
        
        for morris in Morris.all {
            
            if (game.isTile(of: player, at: morris.firstCoordinate) || morris.firstCoordinate == coordinate) &&
               (game.isTile(of: player, at: morris.secondCoordinate) || morris.secondCoordinate == coordinate) &&
               (game.isTile(of: player, at: morris.thirdCoordinate) || morris.thirdCoordinate == coordinate) {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
}
