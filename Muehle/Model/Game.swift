//
//  Game.swift
//  Mühle
//
//  Created by Lennart Fischer on 03.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import Log

protocol GameDelegate {
    
    func place(tile: Tile)
    
    func remove(tile: Tile)
    
    func playerCanRemove(player: Player)
    
    func changedMoving(player: Player)
    
    func changedState(_ state: State)
    
    func move(tile: Tile)
    
    func playerHasWon(_ player: Player)
    
}

class Game {

    // MARK: - Properties
    
    public var delegate: GameDelegate? = nil
    public var state: State = .insert
    public var mode: GameMode = .pvp
    public var playerToMove: Player = .a
    
    public var canMove: Bool {
        
        return state == .move
        
    }
    
    private var turns: [Turn] = []
    private var tiles: [Tile] = []
    private var totalTileCounter = 0
    private var registeredMorris: [Morris] = []
    private var playerCanRemove: Player? = nil
    
    private let log = Logger()
    
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
    
    // MARK: - Methods
    // Private
    
    private func addTile(at coordinate: Coordinate, of player: Player) {
        
        let tile = Tile(coordinate: coordinate, player: player)
        
        tiles.append(tile)
        
        totalTileCounter += 1
        
        delegate?.place(tile: tile)
        
    }
    
    private func newMorris(for player: Player) -> [Morris]? {
        
        var morrises: [Morris] = []
        
        for morris in Morris.all {
            
            if isTile(of: player, at: morris.firstCoordinate) && isTile(of: player, at: morris.secondCoordiante) && isTile(of: player, at: morris.thirdCoordinate) && !registeredMorris.contains(morris) {
                
                morris.player = player
                
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
    
    // ------ Morris
    
    private func register(morris: [Morris]) {
        
        registeredMorris.append(contentsOf: morris)
        
    }
    
    private func updateRegisteredMorrisses() {
        
        let cpRegisteredMorris = registeredMorris
        
        for morris in cpRegisteredMorris {
            
            if !isTile(of: morris.player!, at: morris.firstCoordinate) || !isTile(of: morris.player!, at: morris.secondCoordiante) || !isTile(of: morris.player!, at: morris.thirdCoordinate) {
                
                registeredMorris = registeredMorris.filter { $0 != morris }
                
            }
            
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
    
    // Public
    // --- UI Interaction
    
    public func registerTouch(at coordinate: Coordinate) {
        
        if let removingPlayer = playerCanRemove {
            
            if !isTile(of: removingPlayer, at: coordinate) && !isInMorris(coordinate: coordinate) {
                
                playerCanRemove = nil
                
                guard let tile = tiles.filter({ $0.coordinate == coordinate }).first else { return }
                
                tiles = tiles.filter({ $0.coordinate != coordinate })
                
                updateRegisteredMorrisses()
                
                delegate?.remove(tile: tile)
                
                if playerATiles == 3 && state == .move {
                    
                    // TODO: Implement Jumping
                    
                    state = .jump
                    delegate?.changedState(.jump)
                    
                } else if playerBTiles == 3 && state == .move {
                    
                    state = .jump
                    delegate?.changedState(.jump)
                    
                    // TODO: Implement Jumping
                    
                }
                
                if gameEnded() {
                    
                    if let winningPlayer = winner() {
                        
                        delegate?.playerHasWon(winningPlayer)
                        
                    }
                    
                }
                
                changeCurrentPlayer()
                
                return
                
            }
            
            return
            
        }
        
        if state == .insert {
            
            if !isOccupied(coordinate) {
                
                let player = playerToMove
                
                addTile(at: coordinate, of: player)
                
                if let m = newMorris(for: player) {
                    
                    register(morris: m)
                    
                    log.info("Morris for player \(player.rawValue)")
                    
                    playerCanRemove = player
                    
                    if !everyTileInMorris(for: player == .a ? .b : .a) {
                        
                        delegate?.playerCanRemove(player: player)
                        
                    }
                    
                } else {
                    
                    changeCurrentPlayer()
                    
                    if totalTileCounter == GameConfig.numberOfTiles * 2 {
                        
                        state = .move
                        delegate?.changedState(.move)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    public func register(turn: Turn) {
        
        if state == .move || state == .jump {
            
            if let tile = tiles.filter({ $0.coordinate == turn.originCoordinate }).first {
                
                tile.coordinate = turn.destinationCoordinate
                
            }
            
            turns.append(turn)
            
            if let m = newMorris(for: turn.player) {
                
                register(morris: m)
                
                log.info("Morris for player \(turn.player.rawValue)")
                
                playerCanRemove = turn.player
                
                delegate?.playerCanRemove(player: turn.player)
                
            } else {
                
                changeCurrentPlayer()
                
            }
            
        }
        
    }
    
    // --- Rules
    
    var playerATiles: Int {
        return tiles.filter({ $0.player == Player.a }).count
    }
    
    var playerBTiles: Int {
        return tiles.filter({ $0.player == Player.b }).count
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
    
    public func tile(on coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func isOccupied(_ coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func turnIsAllowed(from coordinate: Coordinate, to destinationCoordinate: Coordinate) -> Bool {
        
        print("turn is allowed: \(validCoordinates(from: coordinate).contains(destinationCoordinate))")
        
        return validCoordinates(from: coordinate).contains(destinationCoordinate)
        
    }
    
    public func isInMorris(coordinate: Coordinate) -> Bool {
        
        for morris in registeredMorris {
            
            if morris.firstCoordinate == coordinate { return true }
            if morris.secondCoordiante == coordinate { return true }
            if morris.thirdCoordinate == coordinate { return true }
            
        }
        
        return false
        
    }
    
    public func everyTileInMorris(for player: Player) -> Bool {
        
        let playerTiles = tiles.filter { $0.player == player }
        
        for tile in playerTiles {
            
            if !isInMorris(coordinate: tile.coordinate) {
                
                return false
                
            }
            
        }
        
        return true
        
    }
    
    public func gameEnded() -> Bool {
        
        if totalTileCounter >= 18 && (playerATiles < 3 || playerBTiles < 3) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    public func winner() -> Player? {
        
        if totalTileCounter >= 18 && playerATiles < 3 {
            
            return Player.b
            
        } else if totalTileCounter >= 18 && playerBTiles < 3 {
            
            return Player.a
            
        } else {
            return nil
        }
        
    }
    
}
