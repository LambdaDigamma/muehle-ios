//
//  MiniMaxAI.swift
//  Muehle
//
//  Created by Lennart Fischer on 28.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

struct AIMove {
    
    var action: Action
    var score = 0
    var coordinate: Coordinate?
    var destinationCoordinate: Coordinate
    
    init(action: Action, coordinate: Coordinate) {
        self.init(action: action, originCoordinate: nil, destinationCoordinate: coordinate)
    }
    
    init(action: Action, originCoordinate: Coordinate?, destinationCoordinate: Coordinate) {
        
        self.action = action
        self.coordinate = originCoordinate
        self.destinationCoordinate = destinationCoordinate
        
    }
    
}


/*class MiniMaxAI: AI {
    
    weak var game: Game!
    
    public var aiPlayer = GameConfig.aiPlayer
    private var depth: Int
    private let maxScore = 1_000_000
    public var bestScore = 0
    
    
    init(game: Game, depth: Int) {
        
        if depth < 1 {
            fatalError("Invalid MiniMax Player Depth")
        }
        
        self.depth = depth
        self.game = game
        
        
    }
    
    func determineTile() -> Coordinate {
        return Coordinate(col: 0, row: 0)
    }
    
    func determineTurn() -> Turn {
        
        return Turn(player: .a, originCoordinate: Coordinate(col: 0, row: 0), destinationCoordinate: Coordinate(col: 0, row: 0))
        
    }
    
    func determineJumpTurn() -> Turn {
        return Turn(player: .a, originCoordinate: Coordinate(col: 0, row: 0), destinationCoordinate: Coordinate(col: 0, row: 0))
    }
    
    func determineRemovingCoordinate() -> Coordinate {
        return Coordinate(col: 0, row: 0)
    }
    
    // MARK: - MiniMax
    
    private func alphaBeta(player: Player, depth: Int, alpha: Int, beta: Int) -> Int {
        
        let state = game.state
        
        let childTurns: [Turn] = []
        
        if depth == 0 {
            
            return evaluate(state: state)
            
        } else if checkGameOver() != 0 {
            
            return checkGameOver()
            
        } else if true {
            
            
            
        } else {
            
            
            
        }
        
        
        return 0
        
    }
    
    private func evaluate(state: State) -> Int {
        
        return 0
        
    }
    
    private func checkGameOver() -> Int {
        
        if game.gameEnded() {
            
            if game.winner() == GameConfig.aiPlayer {
                
                return -maxScore
                
            } else if game.winner() == Player.opponent(of: GameConfig.aiPlayer) {
                
                return maxScore
                
            } else {
                return 0
            }
            
        } else {
            
            return 0
            
        }
        
    }
    
    
}*/
