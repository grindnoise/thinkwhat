//
//  UIFont+.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIFont {
    class func font(fontName: String, forStyle style: UIFont.TextStyle) -> UIFont? {
        switch style {
        case .largeTitle:
            return UIFont(name: fontName, size: 34)!
        case .title1:
            return UIFont(name: fontName, size: 28)!
        case .title2:
            return UIFont(name: fontName, size: 22)!
        case .title3:
            return UIFont(name: fontName, size: 20)!
        case .headline:
            return UIFont(name: fontName, size: 17)!
        case .body:
            return UIFont(name: fontName, size: 17)!
        case .callout:
            return UIFont(name: fontName, size: 16)!
        case .subheadline:
            return UIFont(name: fontName, size: 15)!
        case .footnote:
            return UIFont(name: fontName, size: 13)!
        case .caption1:
            return UIFont(name: fontName, size: 12)!
        case .caption2:
            return UIFont(name: fontName, size: 11)!
        default:
            return nil
        }
    }
    
    class func scaledFont(fontName: String, forTextStyle style: UIFont.TextStyle) -> UIFont? {
        guard let customFont = UIFont.font(fontName: fontName, forStyle: style) else { return nil }
        let metrics = UIFontMetrics(forTextStyle: style)
        let scaledFont = metrics.scaledFont(for: customFont)
        
        return scaledFont
    }
}
