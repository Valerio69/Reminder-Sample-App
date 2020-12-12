//
//  UIFont+Extensions.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/10/20.
//

import UIKit

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    var bold: UIFont {
        return withTraits(traits: .traitBold)
    }
    
    var italic: UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    var semibold: UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: .semibold)
    }
}
