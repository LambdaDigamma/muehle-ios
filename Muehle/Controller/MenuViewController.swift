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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
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
