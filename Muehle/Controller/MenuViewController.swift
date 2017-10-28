//
//  MenuViewController.swift
//  Muehle
//
//  Created by Lennart Fischer on 15.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MenuViewController: UIViewController {

    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        shopButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.imageView?.contentMode = .scaleAspectFit
        themeButton.imageView?.contentMode = .scaleAspectFit
        infoButton.imageView?.contentMode = .scaleAspectFit
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? GameViewController {
            
            if segue.identifier == "pvp" {
                
                vc.mode = .pvp
                
            } else if segue.identifier == "pveeasy" {
                
                vc.mode = .pveEasy
                
            } else if segue.identifier == "pvemedium" {
                
                vc.mode = .pveMedium
                
            } else if segue.identifier == "pvehard" {
                
                vc.mode = .pveHard
                
            }
            
        }
        
    }
    
}
