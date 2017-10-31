//
//  HeuristicNormal.swift
//  Muehle
//
//  Created by Lennart Fischer on 29.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

private let SharedHeuristicNormalInstance = HeuristicNormal()

class HeuristicNormal: Heuristic {
    
    fileprivate init() {
        
    }
    
    static func shared() -> HeuristicNormal {
        return SharedHeuristicNormalInstance
    }
    
    func evaluate(game: Game) -> Int {
        
        // Calculations for Player B
        let numberOfMovesBlack = game.numberOfPossibleMoves(for: .b)
        
        let numberOfStonesBlack = game.numberOfStones(for: .b)
        
        let numberOfPotentialMovesBlack = game.numberOfPotentialMoves(for: .b)
        
        let numberOfOpenMorrisBlack = numberOfOpenMorris(game: game, player: .b)
        
        let numberOfClosedMorrisBlack = numberOfClosedMorris(game: game, player: .b)
        
        // Calculation for Player A
        let numberOfMovesWhite = game.numberOfPossibleMoves(for: .a)
        
        let numberOfStonesWhite = game.numberOfStones(for: .a)
        
        let numberOfPotentialMovesWhite = game.numberOfPotentialMoves(for: .a)
        
        let numberOfOpenMorrisWhite = numberOfOpenMorris(game: game, player: .a)
        
        let numberOfClosedMorrisWhite = numberOfClosedMorris(game: game, player: .a)
        
        // Factors
        var factorOpenMorrisBlack = 200
        var factorOpenMorrisWhite = 200
        var factorClosedMorrisBlack = 100
        var factorClosedMorrisWhite = 100
        let factorMovesBlack = 70
        let factorMovesWhite = 70
        let factorStonesBlack = 10000
        let factorStonesWhite = 10000
        let factorPotentialBlack = 30
        let factorPotentialWhite = 30
        var whiteAddition = 0
        var blackAddition = 0
        
        // Modify Factors
        if game.playerToMove == .b {
            
            factorOpenMorrisBlack = 320
            factorOpenMorrisWhite = 420
            factorClosedMorrisBlack = 20
            factorClosedMorrisWhite = 40
            
        } else if game.playerToMove == .a {
            
            factorOpenMorrisBlack = 420
            factorOpenMorrisWhite = 320
            factorClosedMorrisBlack = 40
            factorClosedMorrisWhite = 20
            
        }
        
        if let winner = game.winner() {
            
            if winner == .b {
                blackAddition += 1000000
            } else if winner == .a {
                whiteAddition += 1000000
            }
            
        }
        
        let blackValue = (numberOfMovesBlack * factorMovesBlack)
            + (numberOfStonesBlack * factorStonesBlack)
            + (numberOfOpenMorrisBlack * factorOpenMorrisBlack)
            + (numberOfClosedMorrisBlack * factorClosedMorrisBlack)
            + (numberOfPotentialMovesBlack * factorPotentialBlack)
        
        let whiteValue = (numberOfMovesWhite * factorMovesWhite)
            + (numberOfStonesWhite * factorStonesWhite)
            + (numberOfOpenMorrisWhite * factorOpenMorrisWhite)
            + (numberOfClosedMorrisWhite * factorClosedMorrisWhite)
            + (numberOfPotentialMovesWhite * factorPotentialWhite)
        
        return (blackValue + blackAddition) - (whiteValue + whiteAddition)
        
    }
    
}
