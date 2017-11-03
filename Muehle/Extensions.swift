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

protocol Copying {
    init(original: Self)
}

// Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

// Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
