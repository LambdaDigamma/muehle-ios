//
//  ShopViewController.swift
//  Muehle
//
//  Created by Lennart Fischer on 17.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import CollectionViewShelfLayout
import BulletinBoard

fileprivate struct CellIdentifier {
    
    static let theme = "themeCell"
    
}

class ShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var themeToBuy: Theme? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var coinsLabel: UILabel!
    
    
    @IBAction func back(_ sender: CustomButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private lazy var confimationBulletinManager: BulletinManager = {
        
        let rootItem = PageBulletinItem(title: "Confim")
        
        rootItem.interfaceFactory.tintColor = UIColor(red: 0.294, green: 0.85, blue: 0.392, alpha: 1)
        rootItem.interfaceFactory.actionButtonTitleColor = .white
        rootItem.actionButtonTitle = "Buy"
        rootItem.alternativeButtonTitle = "Cancel"
        rootItem.descriptionText = "Are you sure you want to buy this theme?"
        
        rootItem.actionHandler = { item in
            
            self.dismiss(animated: true, completion: nil)
            
            guard let theme = self.themeToBuy else { return }
            
            let settings = (UIApplication.shared.delegate as! AppDelegate).settings
                
            settings.registerBuyed(theme: theme)
            
            self.coinsLabel.text = "\(settings.coins) coins"
            
            self.collectionView.reloadData()
            
        }
        
        rootItem.alternativeHandler = { item in
            
            // Dismiss Bulletin
            self.dismiss(animated: true, completion: nil)
            
        }
        
        return BulletinManager(rootItem: rootItem)
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shelfLayout = CollectionViewShelfLayout()
        shelfLayout.cellSize = CGSize(width: 300, height: 300)
        shelfLayout.sectionCellInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.collectionViewLayout = shelfLayout
        
        collectionView.allowsMultipleSelection = false
        
        let coins = (UIApplication.shared.delegate as! AppDelegate).settings.coins
        
        coinsLabel.text = "\(coins) coins"
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Theme.all.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.theme, for: indexPath) as! ShopCollectionViewCell
        
        cell.theme = Theme.all[indexPath.row]
        
        cell.notBought = (UIApplication.shared.delegate as! AppDelegate).settings.buyedThemes[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let settings = (UIApplication.shared.delegate as! AppDelegate).settings
        
        let buyedThemes = settings.buyedThemes
        
        if buyedThemes[indexPath.row] == false && Theme.all[indexPath.row].coins <= settings.coins {
            
            themeToBuy = Theme.all[indexPath.row]
            
            confimationBulletinManager.backgroundViewStyle = .blurredDark
            confimationBulletinManager.prepare()
            confimationBulletinManager.presentBulletin(above: self)
            
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
