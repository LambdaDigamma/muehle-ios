//
//  AIRandom.swift
//  Muehle
//
//  Created by Lennart Fischer on 29.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

private let SharedAIRandomInstance = AIRandom()

class AIRandom: Calculateable {
    
    public static func shared() -> AIRandom {
        return SharedAIRandomInstance
    }
    
    func calculateNextMove(game: Game) -> AIMove {
        
        let possibleMoves = AIPossibleMoves(game: game)
        
        var chosenMove: AIMove!
        
        let fromSize = possibleMoves.fromMove.count
        let toSize = possibleMoves.toMove.count
        
        if fromSize > 0 && toSize > 0 {
            
            let index = fromSize.random()
            
            chosenMove = AIMove(action: possibleMoves.nextAction, originCoordinate: possibleMoves.fromMove[index], destinationCoordinate: possibleMoves.toMove[index])
            
            
        } else if toSize > 0 {
            
            let index = fromSize.random()
            
            chosenMove = AIMove(action: possibleMoves.nextAction, coordinate: possibleMoves.toMove[index])
            
        }
        
        return chosenMove
        
    }
    
}
