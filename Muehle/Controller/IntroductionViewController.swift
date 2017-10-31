//
//  IntroductionViewController.swift
//  Muehle
//
//  Created by Lennart Fischer on 30.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (UIApplication.shared.delegate as! AppDelegate).settings.introductionEnded == true {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController")

            present(vc, animated: false, completion: nil)
            
        } else {
            
            let settings = (UIApplication.shared.delegate as! AppDelegate).settings
            
            var defaultBuyedThemes: [Bool] = []
            
            (0..<Theme.all.count).forEach({ $0 == 0 ? defaultBuyedThemes.append(true) : defaultBuyedThemes.append(false) })
            
            settings.buyedThemes = defaultBuyedThemes
            settings.coins = 1000
            settings.volume = 0.75
            
            settings.introductionEnded = true
            
        }
        
    }
    
}
