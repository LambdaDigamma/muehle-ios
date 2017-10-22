//
//  Theme.swift
//  Muehle
//
//  Created by Lennart Fischer on 17.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

enum BoardColor {
    
    case white
    case black
    
}

struct Theme: Equatable {
    
    var name: String
    var textColor: UIColor
    var boardColor: BoardColor
    var image: UIImage?
    var soundPath: String?
    var playerATexture: UIImage
    var playerBTexture: UIImage
    
    static var all: [Theme] {
        
        return [Theme(name: "Default", textColor: UIColor.black, boardColor: .black, image: nil, soundPath: "Normal Theme.wav", playerATexture: #imageLiteral(resourceName: "standard_blue"), playerBTexture: #imageLiteral(resourceName: "standard_red")), Theme(name: "Space", textColor: UIColor.white, boardColor: .white, image: #imageLiteral(resourceName: "space"), soundPath: "Space Theme.wav", playerATexture: #imageLiteral(resourceName: "rocket_white"), playerBTexture: #imageLiteral(resourceName: "rocket_black"))]
        
    }
    
}

func ==(lhs: Theme, rhs: Theme) -> Bool {
    
    return lhs.name == rhs.name && lhs.textColor == rhs.textColor && lhs.boardColor == rhs.boardColor && lhs.image == rhs.image && lhs.soundPath == rhs.soundPath && lhs.playerATexture == rhs.playerATexture && lhs.playerBTexture == rhs.playerBTexture
    
}
