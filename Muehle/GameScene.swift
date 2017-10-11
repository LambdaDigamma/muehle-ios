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

class GameScene: SKScene, GameDelegate {
    
    // MARK: - Properties
    
    private let log = Logger()
    private var board: SKTileMapNode!
    private var playerLabel: SKLabelNode!
    private var stateLabel: SKLabelNode!
    private var tileSprites: [TileNode] = []
    
    public var game = Game()
    
    private var movingStartCoordinate: Coordinate? = nil
    
    // MARK: - Scene stuff
    
    override func sceneDidLoad() {

        guard let boardMap = childNode(withName: "BoardMapNode") as? SKTileMapNode else {
            fatalError("Board node not loaded")
        }
        guard let playerNode = childNode(withName: "PlayerLabel") as? SKLabelNode else {
            fatalError("Player node not loaded")
        }
        guard let stateNode = childNode(withName: "StateLabel") as? SKLabelNode else {
            fatalError("State node not loaded")
        }
        
        self.board = boardMap
        self.playerLabel = playerNode
        self.stateLabel = stateNode
        
        game.delegate = self
        
    }
    
    // MARK: - Touch
    
    var tempArray = [Coordinate]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
//        let coordinate = getCoordinate(from: touch)
//
//        tempArray.append(coordinate)
//
//        if tempArray.count == 3 {
//            print(tempArray)
//            tempArray = []
//        }
        
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
        
        let coordinate = getCoordinate(from: touch)
        
        if let startCoordiante = movingStartCoordinate {
            
            if game.isValid(coordinate) && !game.isOccupied(coordinate) && game.turnIsAllowed(from: startCoordiante, to: coordinate) {
                
                tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                
            } else if startCoordiante == coordinate {
                
                tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let coordinate = getCoordinate(from: touch)
        
        if let startCoordiante = movingStartCoordinate {
            
            if game.isValid(coordinate) && !game.isOccupied(coordinate) && game.turnIsAllowed(from: startCoordiante, to: coordinate) {
                
                tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                
                game.register(turn: Turn(player: game.playerToMove, originCoordinate: startCoordiante, destinationCoordinate: coordinate))
                
            } else if startCoordiante == coordinate {
                
                tileSprites.filter { $0.tile.coordinate == startCoordiante }.first?.position = center(from: coordinate)
                
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
    
    private func placeTile(_ tile: Tile) {
        
        var color = UIColor.clear
        
        if tile.player == .a {
            color = UIColor.lightGray
        } else {
            color = UIColor.darkGray
        }
        
        let tileSprite = TileNode(color: color, size: CGSize(width: 50, height: 50), tile: tile)
        
        tileSprites.append(tileSprite)
        
        board.addChild(tileSprite)
        
        tileSprite.position = center(from: tile.coordinate)
        
        log.info("Placed tile at \(tile.coordinate)")
        
    }
    
    // MARK: - GameDelegate
    
    func place(tile: Tile) {
        
        placeTile(tile)
        
    }
    
    func move(tile: Tile) {
        
        
        
    }
    
    func playerCanRemove(player: Player) {
        
    }
    
    func changedMoving(player: Player) {
        
        playerLabel.text = "Spieler: \(player.rawValue)"
        
    }
    
    func changedState(_ state: State) {
        
        if state == .move {
            
            stateLabel.text = "Phase: Bewegen"
            
        }
        
        
    }
    
}
