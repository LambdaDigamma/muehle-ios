//
//  SettingsViewController.swift
//  Muehle
//
//  Created by Lennart Fischer on 17.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let settings = (UIApplication.shared.delegate as! AppDelegate).settings
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        
        settings.volume = Double(sender.value)
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        volumeSlider.value = Float(settings.volume)
        
    }

}
