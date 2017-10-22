//
//  TileNode.swift
//  Muehle
//
//  Created by Lennart Fischer on 07.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import SpriteKit

class TileNode: SKSpriteNode {

    var tile: Tile
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(color: UIColor, size: CGSize, tile: Tile) {
        
        self.tile = tile
        
        super.init(texture: nil, color: color, size: size)
        
    }
    
    init(texture: SKTexture?, size: CGSize, tile: Tile) {
        
        self.tile = tile
        
        super.init(texture: texture, color: UIColor.clear, size: size)
        
    }
    
}
