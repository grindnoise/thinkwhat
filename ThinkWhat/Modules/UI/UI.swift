//
//  UI.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

//MARK: - String & fonts



struct StringAttributes {
    enum FontStyle: String {
        case Semibold     = "OpenSans-Semibold"
        case Bold         = "OpenSans-Bold"
        case Regular      = "OpenSans"
        case Light        = "OpenSans-Light"
        case Italic       = "OpenSans-Italic"
        case Extrabold    = "OpenSans-ExtraBold"
        
        func get(size: CGFloat) -> UIFont {
            if let font = UIFont(name: self.rawValue, size: size) {
                return font
            }
            return UIFont()
        }
    }
    static func font(name: String, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont()
    }
    
    static func getAttributes(font: UIFont, foregroundColor: UIColor, backgroundColor: UIColor) -> [NSAttributedString.Key : Optional<NSObject>] {
        var stringAttrs: [NSAttributedString.Key : Optional<NSObject>] = [:]
        
        stringAttrs[NSAttributedString.Key.font]            = font
        stringAttrs[NSAttributedString.Key.foregroundColor] = foregroundColor
        stringAttrs[NSAttributedString.Key.backgroundColor] = backgroundColor
        //        stringAttrs[NSAttributedString.Key.] = backgroundColor
        
        return stringAttrs
    }
    
    struct Fonts {
        struct Style {
            static let Semibold         = "OpenSans-Semibold"
            static let SemiboldItalic   = "OpenSans-SemiboldItalic"
            static let Bold             = "OpenSans-Bold"
            static let Regular          = "OpenSans"
            static let Light            = "OpenSans-Light"
            static let Italic           = "OpenSans-Italic"
            static let Extrabold        = "OpenSans-ExtraBold"
        }
    }
    
    struct SemiBold {
        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 12),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    }
    
    struct Bold {
        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 12),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    }
    
    struct Regular {
        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans", size: 12),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    }
    
}

//MARK: - Colors
let K_COLOR_RED                                 = UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)//C03E45 English Vermillion//UIColor(red:0.805, green: 0.342, blue:0.339, alpha:1)
let K_COLOR_GRAY                                = UIColor(red:0.574, green: 0.574, blue:0.574, alpha:1)
let K_COLOR_TABBAR                              = UIColor(red: 0.416, green: 0.400, blue: 0.639, alpha: 1.000)//UIColor(red: 0.227, green: 0.337, blue: 0.514, alpha: 1.000)//UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)//UIColor(red: 0.035, green: 0.016, blue: 0.275, alpha: 1.000)//UIColor(red: 0.157, green: 0.188, blue: 0.267, alpha: 1.000)//283044 Space Cadet//UIColor(red:0.592, green: 0.46, кblue:0.574, alpha:1)
let K_COLOR_CONTAINER_BG                        = UIColor(red: 0.910, green: 0.929, blue: 0.929, alpha: 1.000)
//let K_COLOR_TABBAR_INACTIVE                     = UIColor(red:0.636, green: 0.636, blue:0.636, alpha:1)
let K_COLOR_PEACH                               = UIColor(red: 0.910, green: 0.929, blue: 0.929, alpha: 1.000)
let K_COLOR_XANADU                              = UIColor(red: 0.482, green: 0.533, blue: 0.435, alpha: 1.000)
let K_COLOR_TUMBLEWEED                          = UIColor(red: 0.945, green: 0.671, blue: 0.525, alpha: 1.000)
let K_COLOR_SPACE_CADET                         = UIColor(red: 0.157, green: 0.188, blue: 0.267, alpha: 1.000)
let K_COLOR_INDIAN_YELLOW                       = UIColor(red: 0.859, green: 0.616, blue: 0.278, alpha: 1.000)
let K_COLOR_DARK_RURPLE                         = UIColor(red: 0.161, green: 0.024, blue: 0.157, alpha: 1.000)

struct Colors {
    struct Banner {
        static let Error             = UIColor(hexString: "#DD1C1A")
        static let Warning           = UIColor(hexString: "#FE7F2D")//UIColor(hexString: "#FCCA46")
        static let Success           = UIColor(hexString: "#A1C181")
        static let Info              = UIColor(hexString: "#619B8A")
    }
    struct UpperButtons {
        static let VioletBlueCrayola = UIColor(hexString: "#7776BC")
        static let Avocado           = UIColor(hexString: "#5C8001")
        static let HoneyYellow       = UIColor(hexString: "#FBB02D")
        static let MaximumRed        = UIColor(hexString: "#DD1C1A")
    }
    struct Tags {

        static let RoyalPurple      = UIColor(hexString: "#6C4FB2")
        static let PacificBlue      = UIColor(hexString: "#47A8BD")
        static let LaserLemon       = UIColor(hexString: "#F0F757")
        static let CoyoteBrown      = UIColor(hexString: "#8F5D35")
        static let EnglishVermillion = UIColor(hexString: "#D14C57")
        static let BudGreen         = UIColor(hexString: "#72BC71")
        static let Corn             = UIColor(hexString: "#F2E86D")
        static let Saffron          = UIColor(hexString: "#F8C630")
        static let OrangeSoda       = UIColor(hexString: "#F2542D")
        static let DarkSlateBlue    = UIColor(hexString: "#4E4187")
        static let BleuDeFrance     = UIColor(hexString: "#3083DC")
        static let SandyBrown       = UIColor(hexString: "#FC9F5B")
        static let CafeNoir         = UIColor(hexString: "#4E3822")
        static let Cardinal         = UIColor(hexString: "#AD343E")
        static let GreenPantone     = UIColor(hexString: "#4DAA57")
        static let HoneyYellow       = UIColor(hexString: "#FBB02D")
        static let VioletBlueCrayola = UIColor(hexString: "#7776BC")
        static let Avocado           = UIColor(hexString: "#5C8001")
    }
    static func tags() -> [UIColor] {
        return [
            Tags.GreenPantone,
            Tags.EnglishVermillion,
            Tags.HoneyYellow,
            Tags.RoyalPurple,
            Tags.Saffron,
            Tags.CoyoteBrown,
            Tags.BudGreen,
            Tags.PacificBlue,
            Tags.LaserLemon,
            Tags.Corn,
            Tags.Saffron,
            Tags.OrangeSoda,
            Tags.DarkSlateBlue,
            Tags.BleuDeFrance,
            Tags.SandyBrown,
            Tags.CafeNoir,
            Tags.Cardinal,

            
            Tags.VioletBlueCrayola,
            Tags.Avocado
        ]
    }
    static let CadetBlue        = UIColor(hexString: "#699999")
    static let RussianViolet    = UIColor(hexString: "#1F2143")
    static let Hyperlink        = UIColor(hexString: "#CAE4F1")
}

//Array of colors used for tag circles in answer cells
