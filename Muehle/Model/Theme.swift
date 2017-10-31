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
    var coins: Int
    var image: UIImage?
    var soundPath: String?
    var playerATexture: UIImage
    var playerBTexture: UIImage
    
    static var all: [Theme] {
        
        return [Theme(name: "Default", textColor: UIColor.black, boardColor: .black, coins: 0, image: nil, soundPath: "Normal Theme.wav", playerATexture: #imageLiteral(resourceName: "standard_blue"), playerBTexture: #imageLiteral(resourceName: "standard_red")),
                Theme(name: "Wood", textColor: UIColor.white, boardColor: .white, coins: 100, image: #imageLiteral(resourceName: "standard"), soundPath: "Normal Theme.wav", playerATexture: #imageLiteral(resourceName: "standard_blue"), playerBTexture: #imageLiteral(resourceName: "standard_red")),
                Theme(name: "Space", textColor: UIColor.white, boardColor: .white, coins: 100, image: #imageLiteral(resourceName: "space"), soundPath: "Space Theme.wav", playerATexture: #imageLiteral(resourceName: "rocket_white"), playerBTexture: #imageLiteral(resourceName: "rocket_black")),
                Theme(name: "Industry", textColor: UIColor.white, boardColor: .white, coins: 100, image: #imageLiteral(resourceName: "industry"), soundPath: "Industry Theme.wav", playerATexture: #imageLiteral(resourceName: "gear_blue"), playerBTexture: #imageLiteral(resourceName: "gear_red")),
                Theme(name: "Snowy", textColor: UIColor.black, boardColor: .black, coins: 100, image: #imageLiteral(resourceName: "snowy"), soundPath: "Snowy Theme.wav", playerATexture: #imageLiteral(resourceName: "sledge_blue"), playerBTexture: #imageLiteral(resourceName: "sledge_red"))]
        
    }
    
}

func ==(lhs: Theme, rhs: Theme) -> Bool {
    
    return lhs.name == rhs.name && lhs.textColor == rhs.textColor && lhs.boardColor == rhs.boardColor && lhs.image == rhs.image && lhs.soundPath == rhs.soundPath && lhs.playerATexture == rhs.playerATexture && lhs.playerBTexture == rhs.playerBTexture
    
}
