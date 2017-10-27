//
//  GameScene.swift
//  Muehle
//
//  Created by Lennart Fischer on 04.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import SpriteKit
import GameplayKit
import Log
import BulletinBoard

class GameScene: SKScene, GameDelegate {
    
    // MARK: - Properties
    
    public var game: Game = Game()
    
    public weak var viewController: GameViewController! {
        didSet { customize(theme: theme) }
    }
    
    public var mode: GameMode = .pvp {
        didSet {
            
            game.mode = mode
            
            if mode == .pvp {

                game = Game.midGame(scene: self)
                game.mode = mode
                game.delegate = self

            } else {

                game.mode = mode
                
            }
            
        }
    }
    
    private let log = Logger()
    private var tileSprites: [TileNode] = []
    private var theme = Theme.all[0]
    private var movingStartCoordinate: Coordinate? = nil
    
    // --- UI
    private var board: SKTileMapNode!
    private var stateLabel: SKLabelNode!
    private var whiteCounterLabel: SKLabelNode!
    private var blackCounterLabel: SKLabelNode!
    private var promptLabel: SKLabelNode!
    private var backgroundSprite: SKSpriteNode!
    
    // MARK: - Scene stuff
    
    override func sceneDidLoad() {

        self.theme = (UIApplication.shared.delegate as! AppDelegate).settings.theme
        
        // Load Board For Theme Color
        let boardNodeName = theme.boardColor == .white ? "WhiteBoardMapNode" : "BoardMapNode"
        
        // Load UI Components From Scene
        guard let boardMap = childNode(withName: boardNodeName) as? SKTileMapNode else { fatalError("Board node not loaded") }
        guard let stateNode = childNode(withName: "StateLabel") as? SKLabelNode else { fatalError("State node not loaded") }
        guard let whiteCounterNode = childNode(withName: "WhiteCounterLabel") as? SKLabelNode else { fatalError("White counter node not loaded") }
        guard let blackCounterNode = childNode(withName: "BlackCounterLabel") as? SKLabelNode else { fatalError("Black counter node not loaded") }
        guard let promptNode = childNode(withName: "PromptLabel") as? SKLabelNode else { fatalError("Prompt node not loaded") }
        guard let backgroundNode = childNode(withName: "BackgroundSprite") as? SKSpriteNode else { fatalError("Background node not loaded") }
        
        self.board = boardMap
        self.stateLabel = stateNode
        self.whiteCounterLabel = whiteCounterNode
        self.blackCounterLabel = blackCounterNode
        self.promptLabel = promptNode
        self.backgroundSprite = backgroundNode
        
        // Bring Board To Top
        self.board.zPosition = 50
        
        game.delegate = self
        
        // Start Background Music For Theme
        startBackgroundMusic()
        
    }
    
    // MARK: - Theming
    
    private func startBackgroundMusic() {
        
        let delayInSeconds = 3.5
        
        // Start Playback after 3.5 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            
            guard let path = self.theme.soundPath else { return }
            
            SKTAudio.sharedInstance().playBackgroundMusic(path)
            
        }
        
    }
    
    private func customize(theme: Theme) {
        
        // Set Background Image From Theme
        if let background = theme.image {
            backgroundSprite.texture = SKTexture(image: background)
        } else {
            backgroundSprite.texture = nil
        }
        
        // Set Font Color
        stateLabel.fontColor = theme.textColor
        whiteCounterLabel.fontColor = theme.textColor
        blackCounterLabel.fontColor = theme.textColor
        promptLabel.fontColor = theme.textColor
        viewController.closeButton.setTitleColor(theme.textColor, for: .normal)
        
    }
    
    // MARK: - Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // TODO: JUMPING LOL, ADD IF
        
        // Get Coordinate From Touch Location
        let coordinate = getCoordinate(from: touch)
        
        if game.playerCanRemove != nil {
            
            validateAndRegisterTouch(at: coordinate)
            
        } else if game.state == .move || game.state == .jump {
            
            // Check For TileSprites At Touched Coordinate And For Player To Move
            if let sprite = tileSprites.filter({ $0.tile.player == game.playerToMove && $0.tile.coordinate == coordinate }).first {
                
                sprite.run(SKAction.scale(to: 1.5, duration: 0.01))
                
                // Set Start Coordinate For Movement
                movingStartCoordinate = coordinate
                
            }
            
        } else {
            
            // Validate Coordinate
            validateAndRegisterTouch(at: coordinate)
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Validate Game State
        if game.state == .move || game.state == .jump {
            
            // Get Coordinate From Touch Location
            let coordinate = getCoordinate(from: touch)
            
            // Validate Start Coordinate
            if let startCoordiante = movingStartCoordinate {
                
                if game.tiles.filter ({ $0.player == game.playerToMove }).count <= 3 {
                    
                    if game.state == .jump {
                        
                        // TODO: Implement Jumping,
                        
                        if game.isValid(coordinate) && !game.isOccupied(coordinate) {
                            
                            // Set New Center
                            tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                            
                        } else if startCoordiante == coordinate {
                            
                            // Reset Tile To Its Old Coordinate
                            tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                            
                        }
                        
                    }
                    
                } else {
                    
                    // TODO: Default moving behaviour
                    
                    // Validate Coordinate And Allowance
                    if game.isValid(coordinate) && !game.isOccupied(coordinate) && game.turnIsAllowed(from: startCoordiante, to: coordinate) {
                        
                        // Set New Center
                        tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                        
                    } else if startCoordiante == coordinate {
                        
                        // Reset Tile To Its Old Coordinate
                        tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get Coordinate From Touch Location
        let coordinate = getCoordinate(from: touch)
        
        // Validate Start Coordinate
        if let startCoordiante = movingStartCoordinate {
            
            if let sprite = tileSprites.filter({ $0.tile.coordinate == startCoordiante }).first {
                
                sprite.run(SKAction.scale(to: 1, duration: 0.01))
                
            }
            
            // Check Game State
            if game.state == .move {
                
                // Validate Coordinate And Allowance
                if game.isValid(coordinate) && !game.isOccupied(coordinate) && game.turnIsAllowed(from: startCoordiante, to: coordinate) {
                    
                    // Set New Center
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                    // Register Turn
                    game.register(turn: Turn(player: game.playerToMove, originCoordinate: startCoordiante, destinationCoordinate: coordinate))
                    
                } else if startCoordiante == coordinate {
                    
                    // Reset Tile To Its Old Coordinate
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                }
                
            } else if game.state == .jump {
                
                // Validate Coordinate And Allowance
                if game.isValid(coordinate) && !game.isOccupied(coordinate) {
                    
                    // Set New Center
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                    // Register Turn
                    game.register(turn: Turn(player: game.playerToMove, originCoordinate: startCoordiante, destinationCoordinate: coordinate))
                    
                } else if startCoordiante == coordinate {
                    
                    // Reset Tile To Its Old Coordinate
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                }
                
            }
            
            // Reset Starting Coordinate
            movingStartCoordinate = nil
            
        }
        
    }
    
    // MARK: - Game
    
    public func load(game: Game) {
        
        self.game = game
        self.game.delegate = self
        
        for tile in self.game.tiles {
            
            place(tile: tile)
            
        }
        
    }
    
    private func getCoordinate(from touch: UITouch) -> Coordinate {
        
        // Adding 1 To Row And Column To Create Non-Zero-Based Coordinate System
        let col = board.tileColumnIndex(fromPosition: touch.location(in: board)) + 1
        let row = board.tileRowIndex(fromPosition: touch.location(in: board)) + 1
        
        return Coordinate(col: col, row: row)
        
    }
    
    private func center(from coordinate: Coordinate) -> CGPoint {
        
        // Caluclate Point From Coordinate
        let point = board.centerOfTile(atColumn: coordinate.col - 1, row: coordinate.row - 1)
        
        return point
        
    }
    
    public func restart() {
        
        game = Game()
        game.delegate = self
        
        for sprite in tileSprites {
            
            sprite.removeFromParent()
            
        }
        
        tileSprites.removeAll()
        
    }
    
    public func validateAndRegisterTouch(at coordinate: Coordinate) {
        
        // Validate Coordinate
        if game.isValid(coordinate) {
            
            // Register Touch In Game Model
            game.registerTouch(at: coordinate)
            
        } else {
            
            log.warning("Invalid touch location")
            
        }
        
    }
    
    private func isAIGameAndAIHasTurn() -> Bool {
        
        return game.mode != .pvp && game.playerToMove == GameConfig.aiPlayer
        
    }
    
    // --- UI
    
    private func placeTile(_ tile: Tile) {
        
        // Get Textures For Player From Theme
        var texture: SKTexture!
        
        if tile.player == .a {
            texture = SKTexture(image: theme.playerATexture)
        } else {
            texture = SKTexture(image: theme.playerBTexture)
        }
        
        // Calculate Tile Size
        let size = CGSize(width: (scene?.size.width)! / 5, height: (scene?.size.width)! / 5)
        
        let tileSprite = TileNode(texture: texture, size: size, tile: tile)
        
        // Add Tile To Scene
        tileSprites.append(tileSprite)
        board.addChild(tileSprite)
        
        tileSprite.position = center(from: tile.coordinate)
        
    }
    
    private func removeTile(_ tile: Tile) {
        
        // Get TileSprite
        guard let sprite = tileSprites.filter({ $0.tile == tile }).first else { return }
        
        // Remove TileSprite
        sprite.removeFromParent()
        
        tileSprites = tileSprites.filter { $0.tile != tile }
        
        log.info("Removed tile at \(tile.coordinate)")
        
    }
    
    private func updateCounterLabels() {
        
        // Update Counter Label
        whiteCounterLabel.text = "\(Player.a.rawValue): \(tileSprites.filter({ $0.tile.player == .a }).count)"
        blackCounterLabel.text = "\(Player.b.rawValue): \(tileSprites.filter({ $0.tile.player == .b }).count)"
        
    }
    
    private func updatePromptLabel(with text: String) {
        
        promptLabel.text = text
        
    }
    
    // MARK: - GameDelegate
    
    func place(tile: Tile) {
        
        if game.mode != .pvp && tile.player == GameConfig.aiPlayer {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                self.placeTile(tile)
                
                self.updateCounterLabels()
                
            })
            
        } else {
            
            placeTile(tile)
            
            print("-----------------------------------")
            print("GAME TILES")
            
            game.tiles.forEach({ (tile) in
                print(tile.coordinate)
            })
            
            print("----------")
            print("UI TILES")
            
            tileSprites.forEach({ (tile) in
                print(tile.tile.coordinate)
            })
            
            print("-----------------------------------")
            
            updateCounterLabels()
            
        }
        
    }
    
    func move(tile: Tile) {
        
    }
    
    func remove(tile: Tile) {
        
        if game.mode != .pvp && tile.player == GameConfig.aiPlayer {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                self.removeTile(tile)
                
                self.updateCounterLabels()
                
            })
            
        } else {
            
            removeTile(tile)
            
            updateCounterLabels()
            
        }
        
    }
    
    func playerCanRemove(player: Player) {
        
        updatePromptLabel(with: "\(player.rawValue) to remove")
        
    }
    
    func changedMoving(player: Player) {
        
        if game.state == .insert {
            
            if !isAIGameAndAIHasTurn() {

                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {

                    self.updatePromptLabel(with: "\(player.rawValue) to set")

                })

            } else {
            
                updatePromptLabel(with: "\(player.rawValue) to set")
                
            }
            
        } else if game.state == .move {
            
            updatePromptLabel(with: "\(player.rawValue) to move")
            
        } else if game.state == .jump {
            
            updatePromptLabel(with: "\(player.rawValue) to jump")
            
        }
        
    }
    
    func changedState(_ state: State) {
        
        if state == .move {
            
            stateLabel.text = "Phase: Move"
            
        } else if state == .jump {
            
            stateLabel.text = "Phase: Jump"
            
        }
        
    }
    
    func playerHasWon(_ player: Player) {
        
        log.info("\(player.rawValue) has won!")
        
        if player == .b && game.mode != .pvp {
            
            viewController.presentLosingBulletin()
            
        } else {
            
            viewController.presentWinningBulletin(for: player, withMode: game.mode)
            
        }
        
    }
    
    func moveAITile(turn: Turn) {
        
//        let point = center(from: turn.destinationCoordinate)
        
        print("Origin: \(turn.originCoordinate)")
        
        print("-------")
        
        for tile in tileSprites {
            
            print(tile.tile.coordinate)
            
        }
        
        print("-------")
        
        print(tileSprites.filter { $0.tile.coordinate == turn.originCoordinate }.first)
        
        tileSprites.filter { $0.tile.coordinate == turn.originCoordinate }.first?.position = center(from: turn.destinationCoordinate)
        
//        tileSprites.filter { $0.tile.coordinate == turn.originCoordinate }.first?.run(SKAction.move(by: CGVector(dx: point.x, dy: point.y), duration: 1.5))
        
    }
    
}
