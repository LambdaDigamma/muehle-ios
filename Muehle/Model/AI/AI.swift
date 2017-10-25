//
//  AI.swift
//  Muehle
//
//  Created by Lennart Fischer on 18.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

protocol AI {
    
    func determineTile() -> Coordinate
    
    func determineTurn() -> Turn
    
    func determineRemovingCoordinate() -> Coordinate
    
}
