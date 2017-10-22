//
//  Settings.swift
//  Muehle
//
//  Created by Lennart Fischer on 17.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class Settings {
    
    private let kWins = "kWins"
    private let kLooses = "kLooses"
    private let kCoins = "kCoins"
    private let kTheme = "kTheme"
    
    var theme: Theme {
        
        get {
            
            let currentTheme = UserDefaults.standard.string(forKey: kTheme)
            
            if let theme = Theme.all.first(where: { $0.name == currentTheme }) {
                
                return theme
                
            } else {
                
                self.theme = Theme.all[0]
                
                return self.theme
                
            }
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue.name, forKey: kTheme)
            
        }
        
    }
    
    var coins: Int {
        
        get {
            
            return UserDefaults.standard.integer(forKey: kCoins)
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: kCoins)
            
        }
        
    }
    
    var wins: Int {
        
        get {
            
            return UserDefaults.standard.integer(forKey: kWins)
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: kWins)
            
        }
        
    }
    
    var looses: Int {
        
        get {
            
            return UserDefaults.standard.integer(forKey: kLooses)
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: kLooses)
            
        }
        
    }
    
    init() {
        
    }
    
}
