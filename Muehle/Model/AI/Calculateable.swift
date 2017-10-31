//
//  Calculateable.swift
//  Muehle
//
//  Created by Lennart Fischer on 29.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

protocol Calculateable {
    
    func calculateNextMove(game: Game) -> AIMove
    
}
