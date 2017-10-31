//
//  AIMiniMax.swift
//  Muehle
//
//  Created by Lennart Fischer on 28.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import Log

class AIMiniMax: Calculateable {
    
    private var heuristic: Decideable
    private var minPlayer: Player!
    private var maxPlayer: Player!
    private var initDepth: Int
    private var dynamicDepth: Int!
    private var indexOfBestMove: Int = 0
    
    fileprivate init(heuristic: Decideable, depth: Int) {
        
        self.heuristic = heuristic
        self.initDepth = depth
        
    }
    
    static func shared(heuristic: Decideable, depth: Int) -> AIMiniMax {
        
        if depth <= 1 {
            
            Logger().warning("Init Depth is lower than 1!")
            
        }
        
        return AIMiniMax(heuristic: heuristic, depth: depth)
        
    }
    
    func calculateNextMove(game: Game) -> AIMove {
        
        let possibleMoves = AIPossibleMoves(game: game)
        
        if possibleMoves.activePlayer == .b {
            
            self.maxPlayer = .b
            self.minPlayer = .a
            
        } else if possibleMoves.activePlayer == .a {
            
            self.maxPlayer = .a
            self.minPlayer = .b
            
        }
        
        // Start AIMiniMax Algorithm
        self.dynamicDepth = initDepth
        
        if possibleMoves.nextAction == .jump && initDepth >= 5 {
            
            self.dynamicDepth = dynamicDepth - 1
            
        }
        
        let _ = calculateMaxValue(depth: self.dynamicDepth, game: game, alpha: Int.min, beta: Int.max)
        
        let chosenMove: AIMove!
        
        if possibleMoves.nextAction == .move || possibleMoves.nextAction == .jump {
            
            chosenMove = AIMove(action: possibleMoves.nextAction, originCoordinate: possibleMoves.fromMove[indexOfBestMove], destinationCoordinate: possibleMoves.toMove[indexOfBestMove])
            
        } else {
            
            chosenMove = AIMove(action: possibleMoves.nextAction, coordinate: possibleMoves.toMove[indexOfBestMove])
            
        }
        
        return chosenMove
        
    }
    
    private func calculateMinValue(depth: Int, game: Game, alpha: Int, beta: Int) -> Int {
        
        var bet = beta
        
        let possibleMoves = AIPossibleMoves(game: game)
        
        if depth <= 0 || possibleMoves.getNumberOfMoves() == 0 {
            
            return getEvaluation(game: game)
            
        }
        
        for i in 0..<possibleMoves.getNumberOfMoves() {
            
            var gameClone = game.copy() as! Game
            
            switch possibleMoves.nextAction {
            case .set:
                gameClone.registerTouch(at: possibleMoves.toMove[i])
                break
            case .move:
                gameClone.register(turn: Turn(player: gameClone.playerToMove, originCoordinate: possibleMoves.fromMove[i], destinationCoordinate: possibleMoves.toMove[i]))
                break
            case .jump:
                gameClone.register(turn: Turn(player: gameClone.playerToMove, originCoordinate: possibleMoves.fromMove[i], destinationCoordinate: possibleMoves.toMove[i]))
                break
            case .remove:
                break
            }
            
            if let _ = gameClone.playerCanRemove {
                
                gameClone = simulateBestRemove(game: gameClone)
                
            }
            
            let calculatedValue = calculateMaxValue(depth: depth - 1, game: gameClone, alpha: alpha, beta: bet)
            
            // Alpha-Cut
            if calculatedValue <= alpha {
                return alpha
            }
            
            if calculatedValue < bet {
                bet = calculatedValue
            }
            
        }
        
        return bet
        
    }
    
    private func calculateMaxValue(depth: Int, game: Game, alpha: Int, beta: Int) -> Int {
        
        var alph = alpha
        
        // Generate All Possible Moves
        let possibleMoves = AIPossibleMoves(game: game)
        
        // Exit Condition: Recursion Depth Reached Or No Possible Turns
        if depth <= 0 || possibleMoves.getNumberOfMoves() <= 0 {
            return getEvaluation(game: game)
        }
        
        // Simulate All Possible Turns
        for i in 0..<possibleMoves.getNumberOfMoves() {
            
            var gameClone = game.copy() as! Game
            
            if depth == dynamicDepth && gameClone.playerCanRemove != nil {
                
                self.indexOfBestMove = calculateBestRemove(game: gameClone)
                
                return 0
                
            }
            
            switch possibleMoves.nextAction {
                
            case .set:
                gameClone.registerTouch(at: possibleMoves.toMove[i])
                break
                
            case .move:
                gameClone.register(turn: Turn(player: gameClone.playerToMove, originCoordinate: possibleMoves.fromMove[i], destinationCoordinate: possibleMoves.toMove[i]))
                break
                
            case .jump:
                gameClone.register(turn: Turn(player: gameClone.playerToMove, originCoordinate: possibleMoves.fromMove[i], destinationCoordinate: possibleMoves.toMove[i]))
                break
                
            case .remove:
                break
                
            }
            
            if let _ = gameClone.playerCanRemove {
                
                gameClone = simulateBestRemove(game: gameClone)
                
            }
            
            if depth == dynamicDepth {
                
                if let winner = gameClone.winner() {
                    
                    if winner == maxPlayer {
                        
                        self.indexOfBestMove = i
                        
                        return 0
                        
                    }
                    
                }
                
            }
            
            let calculatedValue = calculateMinValue(depth: depth - 1, game: gameClone, alpha: alph, beta: beta)
            
            // Beta-Cut
            if calculatedValue >= beta {
                
                return beta
                
            }
            
            if calculatedValue > alph {
                
                alph = calculatedValue
                
                if depth == dynamicDepth {
                    
                    self.indexOfBestMove = i
                    
                }
                
            }
            
        }
        
        return alph
        
    }
    
    private func simulateBestRemove(game: Game) -> Game {
        
        let moves = AIPossibleMoves(game: game)
        
        var bestRemove: Coordinate!
        var bestFoundValue = Int.min
        let evaluationFactor = moves.activePlayer == .a ? -1 : 1
        
        for i in 0..<moves.getNumberOfMoves() {
            
            let gameClone = game.copy() as! Game
            
            gameClone.registerTouch(at: moves.toMove[i])
            
            let calcValue = HeuristicRemove.shared().evaluate(game: game) * evaluationFactor
            
            if calcValue >= bestFoundValue {
                
                bestFoundValue = calcValue
                bestRemove = moves.toMove[i]
                
            }
            
        }
        
        let changedGame = game.copy() as! Game
        changedGame.registerTouch(at: bestRemove)
        
        return changedGame
        
    }
    
    private func calculateBestRemove(game: Game) -> Int {
        
        let possibleMoves = AIPossibleMoves(game: game)
        
        var indexOfBestRemove = 0
        var bestFoundValue = Int.min
        let evaluationFactor = (possibleMoves.activePlayer == .a) ? -1 : 1
        
        // Simulate All Possible Turns
        for i in 0..<possibleMoves.getNumberOfMoves() {
            
            let gameClone = game.copy() as! Game
            gameClone.registerTouch(at: possibleMoves.toMove[i])
            
            let moves = AIPossibleMoves(game: gameClone)
            var minValue = Int.max
            
            // Explore Opponents Opportunities
            for j in 0..<moves.getNumberOfMoves() {
                
                let minClone = gameClone.copy() as! Game
                
                switch moves.nextAction {
                    
                    case .set:
                        minClone.registerTouch(at: moves.toMove[j])
                        break
                    
                    case .move:
                        minClone.register(turn: Turn(player: minClone.playerToMove, originCoordinate: moves.fromMove[j], destinationCoordinate: moves.toMove[j]))
                        break
                    
                    case .jump:
                        minClone.register(turn: Turn(player: minClone.playerToMove, originCoordinate: moves.fromMove[j], destinationCoordinate: moves.toMove[j]))
                        break
                    
                    default: break
                    
                }
                
                let calcValue = HeuristicRemove.shared().evaluate(game: minClone) * evaluationFactor
                
                if calcValue < minValue {
                    
                    minValue = calcValue
                    
                }
                
            }
            
            if minValue >= bestFoundValue {
                
                bestFoundValue = minValue
                indexOfBestRemove = i
                
            }
            
        }
        
        return indexOfBestRemove
        
    }
    
    private func getEvaluation(game: Game) -> Int {
        
        var value = heuristic.evaluate(game: game)
        
        if maxPlayer == .a && minPlayer == .b {
            
            value *= -1
            
        }
        
        return value
        
    }
    
}
