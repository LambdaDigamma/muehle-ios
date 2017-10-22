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
    
    public weak var viewController: GameViewController! {
        didSet {
            customize(theme: theme)
        }
    }
    
    private let log = Logger()
    private var board: SKTileMapNode!
    private var stateLabel: SKLabelNode!
    private var tileSprites: [TileNode] = []
    private var theme = Theme.all[0]
    
    // Labels
    private var whiteCounterLabel: SKLabelNode!
    private var blackCounterLabel: SKLabelNode!
    private var promptLabel: SKLabelNode!
    private var backgroundSprite: SKSpriteNode!
    
    public var game = Game()
    
    private var movingStartCoordinate: Coordinate? = nil
    
    // MARK: - Scene stuff
    
    override func sceneDidLoad() {

        self.theme = (UIApplication.shared.delegate as! AppDelegate).settings.theme
        
        let boardNodeName = theme.boardColor == .white ? "WhiteBoardMapNode" : "BoardMapNode"
        
        guard let boardMap = childNode(withName: boardNodeName) as? SKTileMapNode else {
            fatalError("Board node not loaded")
        }
        
        guard let stateNode = childNode(withName: "StateLabel") as? SKLabelNode else {
            fatalError("State node not loaded")
        }
        
        guard let whiteCounterNode = childNode(withName: "WhiteCounterLabel") as? SKLabelNode else {
            fatalError("White counter node not loaded")
        }
        
        guard let blackCounterNode = childNode(withName: "BlackCounterLabel") as? SKLabelNode else {
            fatalError("Black counter node not loaded")
        }
        
        guard let promptNode = childNode(withName: "PromptLabel") as? SKLabelNode else {
            fatalError("Prompt node not loaded")
        }
        
        guard let backgroundNode = childNode(withName: "BackgroundSprite") as? SKSpriteNode else {
            fatalError("Background node not loaded")
        }
        
        self.board = boardMap
        self.stateLabel = stateNode
        self.whiteCounterLabel = whiteCounterNode
        self.blackCounterLabel = blackCounterNode
        self.promptLabel = promptNode
        self.backgroundSprite = backgroundNode
        
        self.board.zPosition = 50
        
        game.delegate = self
        
        startBackgroundMusic()
        
    }
    
    // MARK: - Theming
    
    private func startBackgroundMusic() {
        
        let delayInSeconds = 3.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            
            guard let path = self.theme.soundPath else { return }
            
            SKTAudio.sharedInstance().playBackgroundMusic(path)
            
        }
        
    }
    
    private func customize(theme: Theme) {
        
        if let background = theme.image {
            backgroundSprite.texture = SKTexture(image: background)
        } else {
            backgroundSprite.texture = nil
        }
        
        stateLabel.fontColor = theme.textColor
        whiteCounterLabel.fontColor = theme.textColor
        blackCounterLabel.fontColor = theme.textColor
        promptLabel.fontColor = theme.textColor
        
        viewController.closeButton.setTitleColor(theme.textColor, for: .normal)
        
    }
    
    // MARK: - Touch
    
    var tempArray = [Coordinate]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let coordinate = getCoordinate(from: touch)
        
        if game.canMove {
            
            if tileSprites.filter({ $0.tile.player == game.playerToMove && $0.tile.coordinate == coordinate }).count > 0 {
                
                movingStartCoordinate = coordinate
                
            }
            
        } else {
            
            if game.isValid(coordinate) {
                
                game.registerTouch(at: coordinate)
                
            } else {
                
                log.warning("Invalid touch location")
                
            }
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if game.state == .move || game.state == .jump {
            
            let coordinate = getCoordinate(from: touch)
            
            if let startCoordiante = movingStartCoordinate {
                
                if game.isValid(coordinate) && !game.isOccupied(coordinate) && game.turnIsAllowed(from: startCoordiante, to: coordinate) {
                    
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                } else if startCoordiante == coordinate {
                    
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                }
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let coordinate = getCoordinate(from: touch)
        
        if let startCoordiante = movingStartCoordinate {
            
            if game.state == .move {
                
                if game.isValid(coordinate) && !game.isOccupied(coordinate) && game.turnIsAllowed(from: startCoordiante, to: coordinate) {
                    
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                    game.register(turn: Turn(player: game.playerToMove, originCoordinate: startCoordiante, destinationCoordinate: coordinate))
                    
                } else if startCoordiante == coordinate {
                    
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                }
                
            } else if game.state == .jump {
                
                if game.isValid(coordinate) && !game.isOccupied(coordinate) {
                    
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                    game.register(turn: Turn(player: game.playerToMove, originCoordinate: startCoordiante, destinationCoordinate: coordinate))
                    
                } else if startCoordiante == coordinate {
                    
                    tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                    
                }
                
            }
            
            movingStartCoordinate = nil
            
        }
        
    }
    
    // MARK: - Game
    
    private func getCoordinate(from touch: UITouch) -> Coordinate {
        
        let col = board.tileColumnIndex(fromPosition: touch.location(in: board)) + 1
        let row = board.tileRowIndex(fromPosition: touch.location(in: board)) + 1
        
        return Coordinate(col: col, row: row)
        
    }
    
    private func center(from coordinate: Coordinate) -> CGPoint {
        
        let point = board.centerOfTile(atColumn: coordinate.col - 1, row: coordinate.row - 1)
        
        return point
        
    }
    
    // --- UI
    
    private func placeTile(_ tile: Tile) {
        
        var texture: SKTexture!
        
        if tile.player == .a {
            texture = SKTexture(image: theme.playerATexture)
        } else {
            texture = SKTexture(image: theme.playerBTexture)
        }
        
        let size = CGSize(width: (scene?.size.width)! / 5, height: (scene?.size.width)! / 5)
        
        let tileSprite = TileNode(texture: texture, size: size, tile: tile)
        
        tileSprites.append(tileSprite)
        
        board.addChild(tileSprite)
        
        tileSprite.position = center(from: tile.coordinate)
        
        log.info("Placed tile at \(tile.coordinate)")
        
    }
    
    private func removeTile(_ tile: Tile) {
        
        guard let sprite = tileSprites.filter({ $0.tile == tile }).first else { return }
        
        sprite.removeFromParent()
        
        tileSprites = tileSprites.filter { $0.tile != tile }
        
        log.info("Removed tile at \(tile.coordinate)")
        
    }
    
    private func updateCounterLabels() {
        
        whiteCounterLabel.text = "\(Player.a.rawValue): \(tileSprites.filter({ $0.tile.player == .a }).count)"
        blackCounterLabel.text = "\(Player.b.rawValue): \(tileSprites.filter({ $0.tile.player == .b }).count)"
        
    }
    
    private func updatePromptLabel(with text: String) {
        
        promptLabel.text = text
        
    }
    
    // MARK: - GameDelegate
    
    func place(tile: Tile) {
        
        placeTile(tile)
        
        updateCounterLabels()
        
    }
    
    func move(tile: Tile) {
        
        
        
    }
    
    func remove(tile: Tile) {
        
        removeTile(tile)
        
        updateCounterLabels()
        
    }
    
    func playerCanRemove(player: Player) {
        
        updatePromptLabel(with: "\(player.rawValue) darf entfernen")
        
    }
    
    func changedMoving(player: Player) {
        
        if game.state == .insert {
            
            updatePromptLabel(with: "\(player.rawValue) darf setzen")
            
        } else if game.state == .move {
            
            updatePromptLabel(with: "\(player.rawValue) am Zug")
            
        } else if game.state == .jump {
            
            updatePromptLabel(with: "\(player.rawValue) darf springen")
            
        }
        
    }
    
    func changedState(_ state: State) {
        
        if state == .move {
            
            stateLabel.text = "Phase: Bewegen"
            
        } else if state == .jump {
            
            stateLabel.text = "Phase: Springen"
            
        }
        
    }
    
    func playerHasWon(_ player: Player) {
        
        log.info("\(player.rawValue) has won!")
        
        
        
    }
    
}
