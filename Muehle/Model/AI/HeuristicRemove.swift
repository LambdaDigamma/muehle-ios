//
//  HeuristicRemove.swift
//  Muehle
//
//  Created by Lennart Fischer on 29.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

private let SharedHeuristicRemoveInstance = HeuristicRemove()

class HeuristicRemove: Heuristic {
    
    fileprivate init() {
        
    }
    
    static func shared() -> HeuristicRemove {
        return SharedHeuristicRemoveInstance
    }
    
    func evaluate(game: Game) -> Int {
        
        var whiteValue = 0
        var blackValue = 0
        
        let numberOfOpenMorrisBlack = numberOfOpenMorris(game: game, player: .b)
        let numberOfOpenMorrisWhite = numberOfOpenMorris(game: game, player: .a)
        
        let numberOfMovesBlack = game.numberOfPossibleMoves(for: .b)
        let numberOfMovesWhite = game.numberOfPossibleMoves(for: .a)
        
        // Factors
        var factorOpenBlack = 100
        var factorOpenWhite = 100
        
        if let removingPlayer = game.playerCanRemove {
            
            if removingPlayer == .a {
                whiteValue += 100000
            } else if removingPlayer == .b {
                blackValue += 100000
            }
            
        }
        
        if game.playerToMove == .a {
            
            factorOpenWhite = 500
            
        } else if game.playerToMove == .b {
            
            factorOpenBlack = 500
            
        }
        
        if let winner = game.winner() {
            
            switch winner {
            case .a: whiteValue += 1000000
            case .b: blackValue += 1000000
            }
            
        }
        
        blackValue += ((numberOfOpenMorrisBlack * factorOpenBlack) + (numberOfMovesBlack * 25));
        whiteValue += ((numberOfOpenMorrisWhite * factorOpenWhite) + (numberOfMovesWhite * 25));
        return (blackValue - whiteValue)
        
    }
    
}
