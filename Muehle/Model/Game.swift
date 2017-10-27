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
    
    func moveAITile(turn: Turn)
    
}

class Game {
    
    // MARK: - Properties
    
    public var delegate: GameDelegate? = nil
    public var state: State = .insert
    public var ai: AI? = nil
    
    public var playerToMove: Player = .a
    
    public var mode: GameMode = .pvp {
        didSet {
            switch mode {
            case .pvp: ai = nil
            case .pveEasy: ai = RandomAI(game: self)
            case .pveMedium: ai = nil
            case .pveHard: ai = nil
            }
        }
    }
    
    public var tiles: [Tile] = []
    private var turns: [Turn] = []
    public var playerCanRemove: Player? = nil
    
    private var totalTileCounter = 0
    private var registeredMorris: [Morris] = []
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
    
    init() {
        
    }
    
    init(mode: GameMode) {
        
        self.mode = mode
        
        switch mode {
        case .pvp: ai = nil
        case .pveEasy: ai = RandomAI(game: self)
        case .pveMedium: ai = nil
        case .pveHard: ai = nil
        }
        
    }
    
    // MARK: - Methods
    
    // Public
    // --- Main Game Event Registering & UI Interaction
    
    public func registerTouch(at coordinate: Coordinate) {
        
        // ------ Touch To Remove
        
        if let removingPlayer = playerCanRemove {
            
            if !isTile(of: removingPlayer, at: coordinate) && !isInMorris(coordinate: coordinate) {
                
                removeTile(at: coordinate)
                
                if (playerATiles == 3 || playerBTiles == 3) && state == .move {
                    
                    // TODO: Implement Jumping
                    
                    state = .jump
                    delegate?.changedState(.jump)
                    
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
        
        // ------ Touch To Set Tile In Insertation State
        
        if state == .insert {
            
            if !isOccupied(coordinate) {
                
                // Add Tile And Check For Morris Of Player Which Has A Turn
                addTileAndCheckMorris(at: coordinate, of: playerToMove)
                
            } else {
                
                log.info("\(playerToMove.rawValue) tried to insert tile at occupied coordinate")
                
            }
            
        }
        
    }
    
    public func register(turn: Turn) {
        
        // TODO: Morris Checking
        
        if state == .move || state == .jump {
            
            executeTurnAndCheckMorris(turn)
            
        }
        
    }
    
    // --- Helper
    
    private func addTileAndCheckMorris(at coordinate: Coordinate, of player: Player) {
        
        // Add Tile To Board (Logic & UI)
        addTile(at: coordinate, of: player)
        
        // Check Game State
        if totalTileCounter == GameConfig.numberOfTiles * 2 {
            
            // Change Game State
            state = .move
            delegate?.changedState(.move)
            
            log.info("Game State changed to 'MOVING'")
            
        }
        
        // Check For New Morris
        if let morris = newMorris(for: player) {
            
            log.info("Morris for player \(player.rawValue)")
            
            // Register Morris
            register(morris: morris)
            
            // Player Can Only Remove Tile When Not All Tiles Of The Opponent Are In A Morris
            if !everyTileInMorris(for: player == .a ? .b : .a) {
                
                // Set Player Which Can Remove A Tile Of The Opponent
                playerCanRemove = player
                
                // Update UI
                delegate?.playerCanRemove(player: player)
                
            }
            
        } else {
            
            // Opponent Has A Turn
            changeCurrentPlayer()
            
        }
        
    }
    
    private func addTile(at coordinate: Coordinate, of player: Player) {
        
        let tile = Tile(coordinate: coordinate, player: player)
        
        tiles.append(tile)
        
        totalTileCounter += 1
        
        delegate?.place(tile: tile)
        
        log.info("Placed tile at \(tile.coordinate)")
        
    }
    
    private func removeTile(at coordinate: Coordinate) {
        
        playerCanRemove = nil
        
        guard let tile = tiles.filter({ $0.coordinate == coordinate }).first else { return }
        
        tiles = tiles.filter({ $0.coordinate != coordinate })
        
        updateRegisteredMorrisses()
        
        delegate?.remove(tile: tile)
        
    }
    
    private func executeTurnAndCheckMorris(_ turn: Turn) {
        
        if let tile = tiles.filter({ $0.coordinate == turn.originCoordinate }).first {
            
            log.info("Logic - Turn: \(turn)")
            
            tile.coordinate = turn.destinationCoordinate
            
        }
        
        turns.append(turn)
        
        if let m = newMorris(for: turn.player) {
            
            register(morris: m)
            
            log.info("Morris for player \(turn.player.rawValue)")
            
            playerCanRemove = turn.player
            
            if !everyTileInMorris(for: turn.player == .a ? .b : .a) {
                
                delegate?.playerCanRemove(player: turn.player)
                
            }
            
        } else {
            
            changeCurrentPlayer()
            
        }
        
        updateRegisteredMorrisses()
        
    }
    
    private func changeCurrentPlayer() {
        
        if playerToMove == .a {
            playerToMove = .b
        } else if playerToMove == .b {
            playerToMove = .a
        }
        
        delegate?.changedMoving(player: playerToMove)
        
        log.info("\(playerToMove.rawValue) has a turn")
        
        if mode != .pvp && playerToMove == GameConfig.aiPlayer {
            
            if state == .insert {
                
                setAITile()
                
            } else if state == .move {
                
                moveAITile()
                
            } else if state == .jump {
                
                if tiles.filter ({ $0.player == playerToMove }).count <= 3 {
                    
                    jumpAITile()
                    
                } else {
                    
                    moveAITile()
                    
                }
                
            }
            
        }
        
    }
    
    // ------ Morris
    
    private func register(morris: [Morris]) {
        
        registeredMorris.append(contentsOf: morris)
        
        log.info("Registered \(morris)")
        
    }
    
    private func updateRegisteredMorrisses() {
        
        let cpRegisteredMorris = registeredMorris
        
        for morris in cpRegisteredMorris {
            
            if !isTile(of: morris.player!, at: morris.firstCoordinate) || !isTile(of: morris.player!, at: morris.secondCoordiante) || !isTile(of: morris.player!, at: morris.thirdCoordinate) {
                
                registeredMorris = registeredMorris.filter { $0 != morris }
                
            }
            
        }
        
        log.info("Updated / Removed not existing morrises")
        
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
    
    // --- Rules
    
    private var playerATiles: Int { return tiles.filter({ $0.player == Player.a }).count }
    
    private var playerBTiles: Int { return tiles.filter({ $0.player == Player.b }).count }
    
    private func isTile(of player: Player, at coordinate: Coordinate) -> Bool {
        
        for tile in tiles {
            
            if tile.player == player && tile.coordinate == coordinate {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    public func allowedTurns(from coordinate: Coordinate) -> [Coordinate] {
        
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
    
    private func validCoordinates(from coordinate: Coordinate) -> [Coordinate] {
        
        return allowedTurns(from: coordinate)
        
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
    
    public func allCoordinates() -> [Coordinate] {
        
        var allCoordinates: [Coordinate] = []
        
        for row in 1..<8 {
            
            for col in 1..<8 {
                
                let cord = Coordinate(col: col, row: row)
                
                if notAllowedCoordinates.filter({ $0 == cord }).count == 0 {
                    
                    allCoordinates.append(cord)
                    
                }
                
            }
            
        }
        
        return allCoordinates
        
    }
    
    public func tile(on coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func isOccupied(_ coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func turnIsAllowed(from coordinate: Coordinate, to destinationCoordinate: Coordinate) -> Bool {
        
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
        
        // Check Whether Player Than Fewer Than 3 Tiles
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
    
    // MARK: - AI
    
    public func setAITile() {
        
        guard let ai = ai else { log.error("AI could not be loaded!"); return }
        
        let coordinate = ai.determineTile()
        
        addTileAndCheckMorris(at: coordinate, of: ai.aiPlayer)
        
        if playerCanRemove != nil {
            
            deleteAIOpponentTile()
            
        }
        
    }
    
    public func moveAITile() {
        
        guard let ai = ai else { log.error("AI could not be loaded!"); return }
        
        let turn = ai.determineTurn()
        
        log.info("AI \(turn)")
        
        executeTurnAndCheckMorris(turn)
        
        delegate?.moveAITile(turn: turn)
        
        if playerCanRemove != nil {
            
            deleteAIOpponentTile()
            
        }
        
    }
    
    public func jumpAITile() {
        
        
        
    }
    
    public func deleteAIOpponentTile() {
        
        guard let ai = ai else { log.error("AI could not be loaded!"); return }
        
        let coordinate = ai.determineRemovingCoordinate()
        
        removeTile(at: coordinate)
        
        changeCurrentPlayer()
        
    }
    
    // MARK: - Game Debug Templates
    
    public static func midGame(scene: GameScene) -> Game {
    
        let game = Game()
        game.delegate = scene
        
        game.registerTouch(at: Coordinate(col: 2, row: 2))
        game.registerTouch(at: Coordinate(col: 6, row: 4))
        game.registerTouch(at: Coordinate(col: 4, row: 6))
        game.registerTouch(at: Coordinate(col: 2, row: 6))
        game.registerTouch(at: Coordinate(col: 7, row: 7))
        game.registerTouch(at: Coordinate(col: 1, row: 1))
        game.registerTouch(at: Coordinate(col: 4, row: 1))
        game.registerTouch(at: Coordinate(col: 6, row: 2))
        game.registerTouch(at: Coordinate(col: 1, row: 4))
        game.registerTouch(at: Coordinate(col: 1, row: 7))
        game.registerTouch(at: Coordinate(col: 3, row: 4))
        game.registerTouch(at: Coordinate(col: 5, row: 4))
        game.registerTouch(at: Coordinate(col: 4, row: 3))
        game.registerTouch(at: Coordinate(col: 7, row: 1))
        game.registerTouch(at: Coordinate(col: 6, row: 6))
        game.registerTouch(at: Coordinate(col: 4, row: 7))
        game.registerTouch(at: Coordinate(col: 3, row: 5))
        game.registerTouch(at: Coordinate(col: 3, row: 3))
        
        
        
        
        
        
        
//        game.registerTouch(at: Coordinate(col: 1, row: 1))
//        game.registerTouch(at: Coordinate(col: 4, row: 1))
//        game.registerTouch(at: Coordinate(col: 7, row: 1))
//        game.registerTouch(at: Coordinate(col: 2, row: 2))
//        game.registerTouch(at: Coordinate(col: 6, row: 4))
//        game.registerTouch(at: Coordinate(col: 6, row: 2))
//        game.registerTouch(at: Coordinate(col: 2, row: 4))
//        game.registerTouch(at: Coordinate(col: 1, row: 7))
//        game.registerTouch(at: Coordinate(col: 3, row: 5))
//        game.registerTouch(at: Coordinate(col: 7, row: 7))
//        game.registerTouch(at: Coordinate(col: 4, row: 7))
//        game.registerTouch(at: Coordinate(col: 5, row: 5))
//        game.registerTouch(at: Coordinate(col: 7, row: 4))
//        game.registerTouch(at: Coordinate(col: 5, row: 3))
//        game.registerTouch(at: Coordinate(col: 3, row: 3))
//        game.registerTouch(at: Coordinate(col: 4, row: 6))
//        game.registerTouch(at: Coordinate(col: 6, row: 6))
//        game.registerTouch(at: Coordinate(col: 2, row: 6))
        
//        Coordinate: (1|1) √
//        Coordinate: (4|1) √
//        Coordinate: (7|1) √
//        Coordinate: (2|2) √
//        Coordinate: (6|4) √
//        Coordinate: (4|2)
//        Coordinate: (1|4)
//        Coordinate: (1|7) √
//        Coordinate: (3|5) √
//        Coordinate: (7|7) √
//        Coordinate: (4|7) √
//        Coordinate: (5|5) √
//        Coordinate: (7|4) √
//        Coordinate: (5|3) √
//        Coordinate: (3|3) √
//        Coordinate: (4|6) √
//        Coordinate: (6|6) √
//        Coordinate: (2|6) √
        
        return game
    
    }
    
    public static func endGame(scene: GameScene) -> Game {
        
        let game = Game()
        game.delegate = scene
        
        game.registerTouch(at: Coordinate(col: 1, row: 1))
        game.registerTouch(at: Coordinate(col: 4, row: 1))
        game.registerTouch(at: Coordinate(col: 7, row: 1))
        game.registerTouch(at: Coordinate(col: 2, row: 2))
        game.registerTouch(at: Coordinate(col: 6, row: 4))
        game.registerTouch(at: Coordinate(col: 6, row: 2))
        game.registerTouch(at: Coordinate(col: 2, row: 4))
        game.registerTouch(at: Coordinate(col: 1, row: 7))
        game.registerTouch(at: Coordinate(col: 3, row: 5))
        game.registerTouch(at: Coordinate(col: 7, row: 7))
        game.registerTouch(at: Coordinate(col: 4, row: 7))
        game.registerTouch(at: Coordinate(col: 5, row: 5))
        game.registerTouch(at: Coordinate(col: 7, row: 4))
        game.registerTouch(at: Coordinate(col: 5, row: 3))
        game.registerTouch(at: Coordinate(col: 3, row: 3))
        game.registerTouch(at: Coordinate(col: 4, row: 6))
        game.registerTouch(at: Coordinate(col: 6, row: 6))
        
        return game
        
    }
    
}
