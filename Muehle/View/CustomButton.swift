//
//  CustomButton.swift
//  Muehle
//
//  Created by Lennart Fischer on 21.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {

    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            
            layer.cornerRadius = cornerRadius
            
        }
    }
    

}
