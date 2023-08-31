//
//  UI.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

struct UISettings {
  struct Shadows {
    static func radius(padding: CGFloat) -> CGFloat { padding*0.65 }
      static let color = UIColor.lightGray.withAlphaComponent(0.35).cgColor
      static let offset = CGSize.zero
  }
}

//struct StringAttributes {
////    enum FontStyle: String {
////        case Semibold     = "OpenSans-Semibold"
////        case Bold         = "OpenSans-Bold"
////        case Regular      = "OpenSans"
////        case Light        = "OpenSans-Light"
////        case Italic       = "OpenSans-Italic"
////        case Extrabold    = "OpenSans-ExtraBold"
////
////        func get(size: CGFloat) -> UIFont {
////            if let font = UIFont(name: self.rawValue, size: size) {
////                return font
////            }
////            return UIFont()
////        }
////    }
//    static func font(name: String, size: CGFloat) -> UIFont {
//        if let font = UIFont(name: name, size: size) {
//            return font
//        }
//        return UIFont()
//    }
//
//    static func getAttributes(font: UIFont, foregroundColor: UIColor, backgroundColor: UIColor) -> [NSAttributedString.Key : Optional<NSObject>] {
//        var stringAttrs: [NSAttributedString.Key : Optional<NSObject>] = [:]
//
//        stringAttrs[NSAttributedString.Key.font]            = font
//        stringAttrs[NSAttributedString.Key.foregroundColor] = foregroundColor
//        stringAttrs[NSAttributedString.Key.backgroundColor] = backgroundColor
//        //        stringAttrs[NSAttributedString.Key.] = backgroundColor
//
//        return stringAttrs
//    }
//
////    struct Fonts {
////        struct Style {
////            static let Semibold         = "OpenSans-Semibold"
////            static let SemiboldItalic   = "OpenSans-SemiboldItalic"
////            static let Bold             = "OpenSans-Bold"
////            static let Regular          = "OpenSans"
////            static let Light            = "OpenSans-Light"
////            static let Italic           = "OpenSans-Italic"
////            static let Extrabold        = "OpenSans-ExtraBold"
////        }
////    }
////
////    struct SemiBold {
////        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 12),
////                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
////                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
////        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 11),
////                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
////                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
////    }
////
////    struct Bold {
////        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 12),
////                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
////                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
////        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 11),
////                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
////                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
////    }
////
////    struct Regular {
////        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans", size: 12),
////                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
////                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
////        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans", size: 11),
////                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
////                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
////    }
//
//}

