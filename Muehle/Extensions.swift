//
//  Extensions.swift
//  Muehle
//
//  Created by Lennart Fischer on 24.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

extension Int {
    func random() -> Int {
        return Int(arc4random_uniform(UInt32(abs(self))))
    }
}
