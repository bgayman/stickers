//
//  UIColor+Application.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit

/// App color pallete
extension UIColor {
    
    static let appBlue = UIColor(red: 54.0 / 255.0, green: 160.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0)
    static let appGreen = UIColor(red: 104.0 / 255.0, green: 192.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    static let appRed = UIColor(red: 244.0 / 255.0, green: 35.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
    static let appYellow = UIColor(red: 238.0 / 255.0 , green: 177.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
    static let appBeige = UIColor(red: 238.0 / 255.0 , green: 234.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
}

extension UIFont {
    
    static func appFont(textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle)
        return appFont(weight: weight, pointSize: preferredFont.pointSize)
    }
    
    static func appFont(weight: UIFont.Weight, pointSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}
