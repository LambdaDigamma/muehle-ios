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
    
    var theme: Theme! {
        didSet {
            
            if theme.name == "Default" {
                themeImageView.image = #imageLiteral(resourceName: "default_preview")
            } else if theme.name == "Space" {
                themeImageView.image = #imageLiteral(resourceName: "space_preview")
            }
            
            nameLabel.text = theme.name
            nameLabel.textColor = theme.textColor
            
            effectView.effect = UIBlurEffect(style: theme.boardColor == .white ? .dark : .extraLight)
            
            layer.cornerRadius = 20
            
//            themeImageView.alpha = 0.65
//            effectView.alpha = 0.65
            
        }
    }
    
}
