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

    public var mode: GameMode = .pvp
    
    private let rootItem = PageBulletinItem(title: "You won!")
    private var gameScene: GameScene!
    
    private lazy var winningBulletinManager: BulletinManager = {
        
        rootItem.image = #imageLiteral(resourceName: "won")
        rootItem.interfaceFactory.tintColor = UIColor(red: 0.294, green: 0.85, blue: 0.392, alpha: 1)
        rootItem.interfaceFactory.actionButtonTitleColor = .white
        rootItem.actionButtonTitle = "Play again"
        rootItem.alternativeButtonTitle = "Not now"
        
        rootItem.actionHandler = { item in
            
            self.gameScene.restart()
            
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
    
    private lazy var losingBulletinManager: BulletinManager = {
        
        let rootItem = PageBulletinItem(title: "You lost!")
        
        rootItem.interfaceFactory.tintColor = UIColor.red
        rootItem.interfaceFactory.actionButtonTitleColor = .white
        
        rootItem.actionButtonTitle = "Play again"
        rootItem.alternativeButtonTitle = "Not now"
        
        rootItem.actionHandler = { item in
            
            self.gameScene.restart()
            
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
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func closeGame(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GKScene(fileNamed: "GameScene") {
            
            if let sceneNode = scene.rootNode as! GameScene? {
                
                self.gameScene = sceneNode
                
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
    
    // MARK: - Game
    
    public func presentWinningBulletin(for player: Player, withMode mode: GameMode) {
        
        if mode == .pvp {
            
            rootItem.descriptionText = "Congratulations! \(player.rawValue) has won!"
            
            winningBulletinManager.backgroundViewStyle = .blurredDark
            winningBulletinManager.prepare()
            winningBulletinManager.presentBulletin(above: self)
            
        } else {
            
            rootItem.descriptionText = "Congratulations! You have won against the AI!"
            
            winningBulletinManager.backgroundViewStyle = .blurredDark
            winningBulletinManager.prepare()
            winningBulletinManager.presentBulletin(above: self)
            
        }
        
    }
    
    public func presentLosingBulletin() {
        
        losingBulletinManager.backgroundViewStyle = .blurredDark
        losingBulletinManager.prepare()
        losingBulletinManager.presentBulletin(above: self)
        
    }
    
}
