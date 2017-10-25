//
//  ThemeViewController.swift
//  Muehle
//
//  Created by Lennart Fischer on 16.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import CollectionViewShelfLayout

struct CellIdentifier {
    
    static let theme = "themeCell"
    
}

class ThemeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func back(_ sender: UIButton) {
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shelfLayout = CollectionViewShelfLayout()
        shelfLayout.cellSize = CGSize(width: 300, height: 300)
        shelfLayout.sectionCellInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.collectionViewLayout = shelfLayout
        
        collectionView.allowsMultipleSelection = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(row: i, section: 0)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ThemeCollectionViewCell {
                
                if cell.theme == (UIApplication.shared.delegate as! AppDelegate).settings.theme {
                    
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                    
                    cell.layer.borderWidth = 4
                    cell.layer.borderColor = UIColor(red: 0.694, green: 0.447, blue: 0.298, alpha: 1.00).cgColor
                    
                }
                
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Theme.all.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.theme, for: indexPath) as! ThemeCollectionViewCell
        
//        cell.isUserInteractionEnabled = false
        
        cell.theme = Theme.all[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ThemeCollectionViewCell {
            
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor(red: 0.694, green: 0.447, blue: 0.298, alpha: 1.00).cgColor
            
            (UIApplication.shared.delegate as! AppDelegate).settings.theme = cell.theme
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ThemeCollectionViewCell {
            
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
            
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
