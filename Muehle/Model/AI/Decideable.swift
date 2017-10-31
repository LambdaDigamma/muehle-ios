//
//  Decideable.swift
//  Muehle
//
//  Created by Lennart Fischer on 28.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

protocol Decideable {
    
    func evaluate(game: Game) -> Int
    
}
