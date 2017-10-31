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
    
    func playerHasWon(_ player: Player)
    
    func moveAITile(turn: Turn)
    
}

class Game: NSCopying {
    
    // MARK: - Properties
    
    public var delegate: GameDelegate? = nil
    public var state: State = .insert
    public var ai: AI? = nil
    
    public var calc: Calculateable? = nil
    
    public var playerToMove: Player = .a
    
    public var mode: GameMode = .pvp {
        didSet {
            switch mode {
            case .pvp: calc = nil
            case .pveEasy: calc = RandomAI.shared() //AIMiniMax.shared(heuristic: HeuristicWeak.shared(), depth: 1)
            case .pveMedium: calc = AIMiniMax.shared(heuristic: HeuristicTest.shared(), depth: 2) // 5
            case .pveHard: calc = AIMiniMax.shared(heuristic: HeuristicStrong.shared(), depth: 2) // 5
            }
        }
    }
    
    private var turns: [Turn] = []
    public var tiles: [Tile] = []
    public var playerCanRemove: Player? = nil
    public var registeredMorris: [Morris] = []
    
    private var totalTileCounter = 0
    private let log = Logger()
    
    public let notAllowedCoordinates = [Coordinate(col: 2, row: 1), Coordinate(col: 3, row: 1), Coordinate(col: 5, row: 1),
                                        Coordinate(col: 6, row: 1), Coordinate(col: 1, row: 2), Coordinate(col: 1, row: 3),
                                        Coordinate(col: 1, row: 5), Coordinate(col: 1, row: 6), Coordinate(col: 2, row: 7),
                                        Coordinate(col: 3, row: 7), Coordinate(col: 5, row: 7), Coordinate(col: 6, row: 7),
                                        Coordinate(col: 7, row: 6), Coordinate(col: 7, row: 5), Coordinate(col: 7, row: 3),
                                        Coordinate(col: 7, row: 2), Coordinate(col: 3, row: 2), Coordinate(col: 2, row: 3),
                                        Coordinate(col: 2, row: 5), Coordinate(col: 3, row: 6), Coordinate(col: 5, row: 6),
                                        Coordinate(col: 6, row: 5), Coordinate(col: 6, row: 3), Coordinate(col: 5, row: 2),
                                        Coordinate(col: 4, row: 4)]
    
    init() {
        
    }
    
    init(mode: GameMode) {
        
        self.mode = mode
        
        switch mode {
        case .pvp: calc = nil
        case .pveEasy: calc = RandomAI.shared() //AIMiniMax.shared(heuristic: HeuristicWeak.shared(), depth: 1)
        case .pveMedium: calc = AIMiniMax.shared(heuristic: HeuristicTest.shared(), depth: 2) // 5
        case .pveHard: calc = AIMiniMax.shared(heuristic: HeuristicStrong.shared(), depth: 2) // 5
        }
        
    }
    
    // MARK: - Methods
    
    // MARK: Event Registering & UI Interaction
    
    public func registerTouch(at coordinate: Coordinate) {
        
        // ------ Touch To Remove
        
        if let removingPlayer = playerCanRemove {
            
            if !isTile(of: removingPlayer, at: coordinate) && !isInMorris(coordinate: coordinate) {
                
                removeTile(at: coordinate)
                
                if (playerATiles == 3 || playerBTiles == 3) && totalTileCounter == 18 {
                    
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
                
//                log.info("\(playerToMove.rawValue) tried to insert tile at occupied coordinate")
                
            }
            
        }
        
    }
    
    public func register(turn: Turn) {
        
        if state == .move || state == .jump {
            
            executeTurnAndCheckMorris(turn)
            
            if gameEnded() {
                
                guard let winner = winner() else { return }
                
                delegate?.playerHasWon(winner)
                
            }
            
        }
        
    }
    
    // MARK: Event Registering Helper
    
    private func addTileAndCheckMorris(at coordinate: Coordinate, of player: Player) {
        
        // Add Tile To Board (Logic & UI)
        addTile(at: coordinate, of: player)
        
        // Check Game State
        if totalTileCounter == GameConfig.numberOfTiles * 2 {
            
            // Change Game State
            state = .move
            delegate?.changedState(.move)
            
//            log.info("Game State changed to 'MOVING'")
            
        }
        
        // Check For New Morris
        if let morris = newMorris(for: player) {
            
//            log.info("Morris for player \(player.rawValue)")
            
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
        
        self.tiles.append(tile)
        
        totalTileCounter += 1
        
        delegate?.place(tile: tile)
        
//        log.info("Placedtile at \(tile.coordinate)")
        
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
            
//            log.info("Logic - Turn: \(turn)")
            
            tile.coordinate = turn.destinationCoordinate
            
        }
        
        turns.append(turn)
        
        if let m = newMorris(for: turn.player) {
            
            register(morris: m)
            
//            log.info("Morris for player \(turn.player.rawValue)")
            
            playerCanRemove = turn.player
            
            if !everyTileInMorris(for: turn.player == .a ? .b : .a) {
                
                delegate?.playerCanRemove(player: turn.player)
                
            }
            
            updateRegisteredMorrisses()
            
        } else {
            
            updateRegisteredMorrisses()
            
            changeCurrentPlayer()
            
        }
        
    }
    
    private func changeCurrentPlayer() {
        
        // Change To Next Player
        if playerToMove == .a {
            playerToMove = .b
        } else if playerToMove == .b {
            playerToMove = .a
        }
        
        delegate?.changedMoving(player: playerToMove)
        
//        log.info("\(playerToMove.rawValue) has a turn")
        
        // Execute AI Move
        if mode != .pvp && playerToMove == GameConfig.aiPlayer {
            
            guard let move = calc?.calculateNextMove(game: self) else { fatalError("Unable to calculate next AI move") }
            
            switch move.action {
            case .set:
                
                let coordinate = move.destinationCoordinate
                
                addTileAndCheckMorris(at: coordinate, of: GameConfig.aiPlayer)
                
                if playerCanRemove != nil {
                    
                    executeRemovingTurn()
                    
                }
                
                break
                
            case .move:
                
                let turn = Turn(player: GameConfig.aiPlayer, originCoordinate: move.coordinate!, destinationCoordinate: move.destinationCoordinate)
                
//                log.info("AI \(turn)")
                
                executeTurnAndCheckMorris(turn)
                
                delegate?.moveAITile(turn: turn)
                
                if playerCanRemove != nil {
                    
                    executeRemovingTurn()
                    
                }
                
                break
                
            case .jump:
                
                let turn = Turn(player: GameConfig.aiPlayer, originCoordinate: move.coordinate!, destinationCoordinate: move.destinationCoordinate)
                
//                log.info("AI \(turn)")
                
                executeTurnAndCheckMorris(turn)
                
                delegate?.moveAITile(turn: turn)
                
                if playerCanRemove != nil {
                    
                    executeRemovingTurn()
                    
                }
                
                break
                
            case .remove:
                fatalError("Should not go here!")
                
                break
                
            }
            
        }
        
    }
    
    // MARK: Morris
    
    private func register(morris: [Morris]) {
        
        registeredMorris.append(contentsOf: morris)
        
//        log.info("Registered \(morris)")
        
    }
    
    private func updateRegisteredMorrisses() {
        
        let cpRegisteredMorris = registeredMorris
        
        for morris in cpRegisteredMorris {
            
            if !isTile(of: morris.player!, at: morris.firstCoordinate) || !isTile(of: morris.player!, at: morris.secondCoordinate) || !isTile(of: morris.player!, at: morris.thirdCoordinate) {
                
                registeredMorris = registeredMorris.filter { $0 != morris }
                
            }
            
        }
        
//        log.info("Updated / Removed not existing morrises")
        
    }
    
    private func newMorris(for player: Player) -> [Morris]? {
        
        var morrises: [Morris] = []
        
        for morris in Morris.all {
            
            if isTile(of: player, at: morris.firstCoordinate) && isTile(of: player, at: morris.secondCoordinate) && isTile(of: player, at: morris.thirdCoordinate) && !registeredMorris.contains(morris) {
                
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
    
    // MARK: - Rules
    
    // MARK: Runtime
    
    private var playerATiles: Int { return tiles.filter({ $0.player == Player.a }).count }
    
    private var playerBTiles: Int { return tiles.filter({ $0.player == Player.b }).count }
    
    public func tile(on coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func isOccupied(_ coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.coordinate == coordinate }).count > 0
        
    }
    
    public func isInMorris(coordinate: Coordinate) -> Bool {
        
        for morris in registeredMorris {
            
            if morris.firstCoordinate == coordinate { return true }
            if morris.secondCoordinate == coordinate { return true }
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
    
    public func playerCanJump(_ player: Player) -> Bool {
        
        return (tiles.filter({ $0.player == player }).count <= 3) && state == .jump
        
    }
    
    public func player(on coordinate: Coordinate) -> Player? {
        
        return tiles.filter({ $0.coordinate == coordinate }).first?.player
        
    }
    
    public func isAIGameAndAIHasTurn() -> Bool {
        
        return mode != .pvp && playerToMove == GameConfig.aiPlayer
        
    }
    
    public func isTile(of player: Player, at coordinate: Coordinate) -> Bool {
        
        return tiles.filter({ $0.player == player && $0.coordinate == coordinate }).count > 0
        
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
    
    // MARK: Definitions
    
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
    
    public func turnIsAllowed(from coordinate: Coordinate, to destinationCoordinate: Coordinate) -> Bool {
        
        return validCoordinates(from: coordinate).contains(destinationCoordinate)
        
    }
    
    // MARK: - Debug
    
    public func plot() {
        
        print("-------")

        for row in (1..<8).reversed() {
            
            var rowString = ""
            
            for col in 1..<8 {

                let coordinate = Coordinate(col: col, row: row)
                
                if player(on: coordinate) == nil {

                    rowString += ". "
                    
                } else {

                    let p = player(on: coordinate) == .a ? "O " : "X "
                    
                    rowString += p
                    
                }

            }

            print(rowString)

        }
        
        print("-------")
        
    }
    
    // MARK: - AI
    
    public func executeRemovingTurn() {
        
        guard let removingMove = calc?.calculateNextMove(game: self) else { fatalError("Unable to calculate AI removing") }
        
        if removingMove.action == .remove {
            
            let coordinate = removingMove.destinationCoordinate
            
            removeTile(at: coordinate)
            
            if (playerATiles == 3 || playerBTiles == 3) && totalTileCounter >= 18 {
                
                state = .jump
                delegate?.changedState(.jump)
                
            }
            
            changeCurrentPlayer()
            
        } else {
            
            fatalError("Should be a removing move")
            
        }
        
    }
    
    public func numberOfPossibleMoves(for player: Player) -> Int {
        
        var allPossibleTurns: [Turn] = []
        
        for tile in tiles.filter({ $0.player == player }) {
            
            for destination in allowedTurns(from: tile.coordinate) {
                
                if !isOccupied(destination) {
                    
                    allPossibleTurns.append(Turn(player: player, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                    
                }
                
            }
            
        }
        
        return allPossibleTurns.count
        
    }
    
    public func numberOfPotentialMoves(for player: Player) -> Int {
        
        var allPotentialTurns: [Turn] = []
        
        for tile in tiles.filter({ $0.player == player }) {
            
            for destination in allowedTurns(from: tile.coordinate) {
                
                allPotentialTurns.append(Turn(player: player, originCoordinate: tile.coordinate, destinationCoordinate: destination))
                
            }
            
        }
        
        return allPotentialTurns.count
        
    }
    
    public func numberOfStones(for player: Player) -> Int {
        
        return tiles.filter({ $0.player == player }).count
        
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let game = Game()
        
        game.mode = .pvp
        game.calc = nil
        game.state = self.state
        game.playerToMove = self.playerToMove
        game.turns = self.turns
        game.tiles = self.tiles
        game.playerCanRemove = self.playerCanRemove
        game.totalTileCounter = self.totalTileCounter
        game.registeredMorris = self.registeredMorris
        
        return game
        
    }

    
}
