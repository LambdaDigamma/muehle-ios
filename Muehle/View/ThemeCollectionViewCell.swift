//
//  ThemeCollectionViewCell.swift
//  Muehle
//
//  Created by Lennart Fischer on 20.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var themeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    var disabled: Bool = false {
        didSet {
            
            if disabled == true {
                
                themeImageView.alpha = 0.65
                effectView.alpha = 0.65
                
            }
            
        }
    }
    
    var theme: Theme! {
        didSet {
            
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
            
            effectView.effect = UIBlurEffect(style: theme.boardColor == .white ? .dark : .extraLight)
            
            
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
            layer.cornerRadius = 20
            
        }
    }
    
}
