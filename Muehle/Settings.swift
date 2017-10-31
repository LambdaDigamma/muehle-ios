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
    private let kGame = "kGame"
    private let kBuyedThemes = "kBuyedThemes"
    private let kIntroduction = "kIntroductionEnded"
    private let kVolume = "kVolume"
    
    var introductionEnded: Bool {
        
        get {
            
            return UserDefaults.standard.bool(forKey: kIntroduction)
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: kIntroduction)
            
        }
        
    }
    
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
    
    var buyedThemes: [Bool] {
        
        get {
            
            return UserDefaults.standard.object(forKey: kBuyedThemes) as? [Bool] ?? []
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: kBuyedThemes)
            
        }
        
    }
    
    func registerBuyed(theme: Theme) {
        
        var changeIndex: Int!
        
        for (i, t) in Theme.all.enumerated() {
            
            if t == theme {
                
                changeIndex = i
                
            }
            
        }
        
        var cp = buyedThemes
        
        cp[changeIndex] = true
        
        buyedThemes = cp
        
        coins -= theme.coins
        
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
    
    var volume: Double {
        
        get {
            
            return UserDefaults.standard.double(forKey: kVolume)
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: kVolume)
            
        }
        
    }
    
    init() {
        
    }
    
}
