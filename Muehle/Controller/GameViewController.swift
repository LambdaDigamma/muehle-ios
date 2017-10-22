//
//  GameViewController.swift
//  Muehle
//
//  Created by Lennart Fischer on 04.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import BulletinBoard

class GameViewController: UIViewController {

    var mode: GameMode = .pvp
    
    lazy var winningBulletinManager: BulletinManager = {
        
        let rootItem = PageBulletinItem(title: "You won!")
        
        rootItem.descriptionText = "Congratulations! You have won!"
        rootItem.image = #imageLiteral(resourceName: "won")
        rootItem.interfaceFactory.tintColor = UIColor(red: 0.294, green: 0.85, blue: 0.392, alpha: 1) // green
        rootItem.interfaceFactory.actionButtonTitleColor = .white
        rootItem.actionButtonTitle = "Play again"
        rootItem.alternativeButtonTitle = "Not now"
        
        rootItem.actionHandler = { item in
            
            
            
        }
        
        rootItem.alternativeHandler = { item in
            
            // Dismiss Bulletin
            self.dismiss(animated: true, completion: nil)
            
            // Dismiss To Menu After .5 sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                self.dismiss(animated: true, completion: nil)
                
            })
            
        }
        
        return BulletinManager(rootItem: rootItem)
        
    }()
    
    lazy var losingBulletinManager: BulletinManager = {
        
        let rootItem = PageBulletinItem(title: "You lost!")
        
        return BulletinManager(rootItem: rootItem)
        
    }()
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func closeGame(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GKScene(fileNamed: "GameScene") {
            
            if let sceneNode = scene.rootNode as! GameScene? {
                
                sceneNode.viewController = self
                
                sceneNode.game.mode = mode
                
                sceneNode.backgroundColor = UIColor.white
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        winningBulletinManager.backgroundViewStyle = .blurredDark
        winningBulletinManager.prepare()
        winningBulletinManager.presentBulletin(above: self)
        
    }
    
    // MARK: - Game
    
    public func presentWinningBulletin(for player: Player, withDifficulty difficulty: Difficulty) {
        
        
        
    }
    
}
