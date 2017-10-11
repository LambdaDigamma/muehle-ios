//
//  Game.swift
//  Mühle
//
//  Created by Lennart Fischer on 03.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

protocol GameDelegate {
    
    func place(tile: Tile)
    
    func playerCanRemove(player: Player)
    
    func changedMoving(player: Player)
    
    func changedState(_ state: State)
    
    func move(tile: Tile)
    
}

class Game {

    // MARK: - Properties
    
    public var delegate: GameDelegate? = nil
    public var state: State = .insert
    public var playerToMove: Player = .a
    
    private var grid = Array2D<Tile>(columns: 7, rows: 7)
    
    private var turns: [Turn] = []
    private var tiles: [Tile] = []
    
    private var totalTileCounter = 0
    
    private var registeredMorris: [Morris] = []
    
    public let notAllowedCoordinates = [Coordinate(col: 2, row: 1),
                                 Coordinate(col: 3, row: 1),
                                 Coordinate(col: 5, row: 1),
                                 Coordinate(col: 6, row: 1),
                                 Coordinate(col: 1, row: 2),
                                 Coordinate(col: 1, row: 3),
                                 Coordinate(col: 1, row: 5),
                                 Coordinate(col: 1, row: 6),
                                 Coordinate(col: 2, row: 7),
                                 Coordinate(col: 3, row: 7),
                                 Coordinate(col: 5, row: 7),
                                 Coordinate(col: 6, row: 7),
                                 Coordinate(col: 7, row: 6),
                                 Coordinate(col: 7, row: 5),
                                 Coordinate(col: 7, row: 3),
                                 Coordinate(col: 7, row: 2),
                                 Coordinate(col: 3, row: 2),
                                 Coordinate(col: 2, row: 3),
                                 Coordinate(col: 2, row: 5),
                                 Coordinate(col: 3, row: 6),
                                 Coordinate(col: 5, row: 6),
                                 Coordinate(col: 6, row: 5),
                                 Coordinate(col: 6, row: 3),
                                 Coordinate(col: 5, row: 2),
                                 Coordinate(col: 4, row: 4)]
    
    private var playerCanRemove: Player? = nil
    
    private var hasMorris: Bool {
        
        // TODO: - Implement Morris checking
        
        return false
        
    }
    
    
    
    public var canMove: Bool {
        
        return state == .move
        
    }
    
    // MARK: - Methods
    
    private func addTile(at coordinate: Coordinate, of player: Player) {
        
        let tile = Tile(coordinate: coordinate, player: player)
        
        tiles.append(tile)
        
        totalTileCounter += 1
        
        delegate?.place(tile: tile)
        
    }
    
    private func morris(for player: Player) -> [Morris]? {
        
        var morrises: [Morris] = []
        
        for morris in Morris.all {
            
            if isTile(of: player, at: morris.firstCoordinate) && isTile(of: player, at: morris.secondCoordiante) && isTile(of: player, at: morris.thirdCoordinate) && !registeredMorris.contains(morris) {
                
                morrises.append(morris)
                
            }
            
        }
        
        if morrises.count == 0 {
            return nil
        } else {
            return morrises
        }
        
    }
     
    private func changeCurrentPlayer() {
        
        if playerToMove == .a {
            playerToMove = .b
        } else if playerToMove == .b {
            playerToMove = .a
        }
        
        delegate?.changedMoving(player: playerToMove)
        
    }
    
    public func registerTouch(at coordinate: Coordinate) {
        
        if let removingPlayer = playerCanRemove {
            
            if !isTile(of: removingPlayer, at: coordinate) {
                
                // TO-DO: Implement removing
                
                playerCanRemove = nil
                
                return
                
            }
            
        }
        
        if state == .insert {
            
            if !isOccupied(coordinate) {
                
                let player = playerToMove
                
                addTile(at: coordinate, of: player)
                
                if let _ = morris(for: player) {
                    
                    print("MORRIS!")
                    
                    playerCanRemove = player
                    
                    delegate?.playerCanRemove(player: player)
                    
                } else {
                    
                    changeCurrentPlayer()
                    
                    if totalTileCounter == 18 {
                        
                        delegate?.changedState(.move)
                        state = .move
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    public func register(turn: Turn) {
        
        if let tile = tiles.filter({ $0.coordinate == turn.originCoordinate }).first {
            
            tile.coordinate = turn.destinationCoordinate
            
        }
        
        turns.append(turn)
    
        changeCurrentPlayer()
        
    }
    
    private func register(morris: Morris) {
        
        registeredMorris.append(morris)
        
    }
    
    private func updateRegisteredMorrisses() {
        
        let cpRegisteredMorris = registeredMorris
        
        for morris in cpRegisteredMorris {
            
            if !isTile(of: morris.player, at: morris.firstCoordinate) || !isTile(of: morris.player, at: morris.secondCoordiante) || !isTile(of: morris.player, at: morris.thirdCoordinate) {
                
                registeredMorris = registeredMorris.filter { $0 == morris }
                
            }
            
        }
        
    }
    
    public func isValid(_ coordinate: Coordinate) -> Bool {
        
        if coordinate.col > 0 && coordinate.col < 8 && coordinate.row > 0 && coordinate.row < 8 {
            
            var allCoordinates: [Coordinate] = []
            
            for row in 1..<8 {
                
                for col in 1..<8 {
                    
                    let cord = Coordinate(col: col, row: row)
                    
                    if notAllowedCoordinates.filter({ $0 == cord }).count == 0 {
                        
                        allCoordinates.append(cord)
                        
                    }
                    
                }
                
            }
            
            return allCoordinates.contains(coordinate)
            
        } else {
            
            return false
            
        }
        
    }
    
    private func isTile(of player: Player, at coordinate: Coordinate) -> Bool {
        
        for tile in tiles {
            
            if tile.player == player && tile.coordinate == coordinate {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    public func tile(on coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func isOccupied(_ coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    private func validCoordinates(from coordinate: Coordinate) -> [Coordinate] {
        
        let allowedTurns: [Coordinate: [Coordinate]] = [
            
            // Corners Outer Row
            Coordinate(col: 1, row: 1): [Coordinate(col: 1, row: 4), Coordinate(col: 4, row: 1)],
            Coordinate(col: 7, row: 1): [Coordinate(col: 4, row: 1), Coordinate(col: 7, row: 4)],
            Coordinate(col: 7, row: 7): [Coordinate(col: 7, row: 4), Coordinate(col: 4, row: 7)],
            Coordinate(col: 1, row: 7): [Coordinate(col: 4, row: 7), Coordinate(col: 1, row: 4)],
            
            // Corners Middle Row
            Coordinate(col: 2, row: 2): [Coordinate(col: 2, row: 4), Coordinate(col: 4, row: 2)],
            Coordinate(col: 6, row: 2): [Coordinate(col: 4, row: 2), Coordinate(col: 6, row: 4)],
            Coordinate(col: 6, row: 6): [Coordinate(col: 6, row: 4), Coordinate(col: 4, row: 6)],
            Coordinate(col: 2, row: 6): [Coordinate(col: 4, row: 6), Coordinate(col: 2, row: 4)],
            
            // Corners Inner Row
            Coordinate(col: 3, row: 3): [Coordinate(col: 3, row: 4), Coordinate(col: 4, row: 3)],
            Coordinate(col: 5, row: 3): [Coordinate(col: 4, row: 3), Coordinate(col: 5, row: 4)],
            Coordinate(col: 5, row: 5): [Coordinate(col: 5, row: 4), Coordinate(col: 4, row: 5)],
            Coordinate(col: 3, row: 5): [Coordinate(col: 4, row: 5), Coordinate(col: 3, row: 4)],
            
            // Middle Outer Row
            Coordinate(col: 1, row: 4): [Coordinate(col: 1, row: 1), Coordinate(col: 2, row: 4), Coordinate(col: 1, row: 7)],
            Coordinate(col: 4, row: 1): [Coordinate(col: 1, row: 1), Coordinate(col: 4, row: 2), Coordinate(col: 7, row: 1)],
            Coordinate(col: 7, row: 4): [Coordinate(col: 7, row: 1), Coordinate(col: 6, row: 4), Coordinate(col: 7, row: 7)],
            Coordinate(col: 4, row: 7): [Coordinate(col: 1, row: 7), Coordinate(col: 4, row: 6), Coordinate(col: 7, row: 7)],
            
            // Middle Middle Row
            Coordinate(col: 2, row: 4): [Coordinate(col: 1, row: 4), Coordinate(col: 2, row: 6), Coordinate(col: 3, row: 4), Coordinate(col: 2, row: 2)],
            Coordinate(col: 4, row: 2): [Coordinate(col: 2, row: 2), Coordinate(col: 4, row: 3), Coordinate(col: 6, row: 2), Coordinate(col: 4, row: 1)],
            Coordinate(col: 6, row: 4): [Coordinate(col: 5, row: 4), Coordinate(col: 6, row: 6), Coordinate(col: 7, row: 4), Coordinate(col: 6, row: 2)],
            Coordinate(col: 4, row: 6): [Coordinate(col: 2, row: 6), Coordinate(col: 4, row: 7), Coordinate(col: 6, row: 6), Coordinate(col: 4, row: 5)],
            
            // Middle Inner Row
            Coordinate(col: 3, row: 4): [Coordinate(col: 2, row: 4), Coordinate(col: 3, row: 3), Coordinate(col: 3, row: 3)],
            Coordinate(col: 4, row: 3): [Coordinate(col: 3, row: 3), Coordinate(col: 4, row: 2), Coordinate(col: 5, row: 3)],
            Coordinate(col: 5, row: 4): [Coordinate(col: 5, row: 3), Coordinate(col: 5, row: 5), Coordinate(col: 6, row: 4)],
            Coordinate(col: 4, row: 5): [Coordinate(col: 3, row: 5), Coordinate(col: 4, row: 6), Coordinate(col: 5, row: 5)]
            
        ]
        
        if let turns = allowedTurns[coordinate] {
            
            return turns
            
        } else {
            
            return []
            
        }
        
    }
    
    public func turnIsAllowed(from coordinate: Coordinate, to destinationCoordinate: Coordinate) -> Bool {
        
        print("turn is allowed: \(validCoordinates(from: coordinate).contains(destinationCoordinate))")
        
        return validCoordinates(from: coordinate).contains(destinationCoordinate)
        
    }
    
}
