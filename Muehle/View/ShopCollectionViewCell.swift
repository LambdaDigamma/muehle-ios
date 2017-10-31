//
//  ShopCollectionViewCell.swift
//  Muehle
//
//  Created by Lennart Fischer on 30.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var themeImageView: UIImageView!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    
    var notBought: Bool = false {
        didSet {
            
            if notBought {
                
                coinsLabel.text = "✔︎"
                coinImageView.isHidden = true
                
            }
            
        }
    }
    
    var theme: Theme! {
        didSet {
            
            coinImageView.isHidden = false
            
            if theme.name == "Default" {
                themeImageView.image = #imageLiteral(resourceName: "default_preview")
            } else if theme.name == "Wood" {
                themeImageView.image = #imageLiteral(resourceName: "wood_preview")
            } else if theme.name == "Space" {
                themeImageView.image = #imageLiteral(resourceName: "space_preview")
            } else if theme.name == "Industry" {
                themeImageView.image = #imageLiteral(resourceName: "industry_preview")
            } else if theme.name == "Snowy" {
                themeImageView.image = #imageLiteral(resourceName: "snowy__preview")
            }
            
            nameLabel.text = theme.name
            nameLabel.textColor = theme.textColor
            
            coinsLabel.text = "\(theme.coins)"
            coinsLabel.textColor = theme.textColor
            
            effectView.effect = UIBlurEffect(style: theme.boardColor == .white ? .dark : .extraLight)
            
            layer.cornerRadius = 20
            
        }
    }
    
}
