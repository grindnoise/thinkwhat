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

struct ColorsStruct {
//    struct Logo {
//        static let Flame            = (main: UIColor(hexString: "#e4572e"), minusTone: UIColor(hexString: "#e76945"))
//        static let LightSteelBlue   = (main: UIColor(hexString: "#AFC2D5"), minusTone: UIColor(hexString: "#afbfd5"))
//        static let Marigold         = (main: UIColor(hexString: "#F3A712"), minusTone: UIColor(hexString: "#f4b02a"))
//        static let Olivine          = (main: UIColor(hexString: "#A8C686"), minusTone: UIColor(hexString: "#b4ce97"))
//        static let AirBlue          = (main: UIColor(hexString: "#669BBC"), minusTone: UIColor(hexString: "#78a7c4"))
//    }
    
    
    
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

enum Colors {
    case system(System)
    case logo(Logo)
    case tag(Tag)
    
    enum System: RawRepresentable, CaseIterable {
        typealias RawValue = UIColor
        
        case Red//Persian red
        case Purple
        
        init?(rawValue: RawValue) {
            switch rawValue.toHexString().lowercased() {
            case "#cc3333".lowercased(): self = .Red
            case "#666699".lowercased(): self = .Purple
            default: return nil
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .Red:      return UIColor(hexString: "#cc3333")
            case .Purple:   return UIColor(hexString: "#666699")
            }
        }
        
        public func next() -> System {
            switch self {
            case .Red: return .Purple
            case .Purple: return .Red
            }
        }
    }
    
    enum Logo: RawRepresentable, CaseIterable {
        typealias RawValue = UIColor
        
        case Flame            //= UIColor(hexString: "#e4572e")
        case CoolGray   //= UIColor(hexString: "#AFC2D5")
        case Marigold         //= UIColor(hexString: "#F3A712")
        case GreenMunshell          //= UIColor(hexString: "#A8C686")
        case AirBlue          //= UIColor(hexString: "#669BBC")
        
        init?(rawValue: RawValue) {
            switch rawValue.toHexString().lowercased() {
            case "#e4572e".lowercased(): self = .Flame
            case "#8B8BAE".lowercased(): self = .CoolGray
            case "#F3A712".lowercased(): self = .Marigold
            case "#00A878".lowercased(): self = .GreenMunshell
            case "#669BBC".lowercased(): self = .AirBlue
            default: return nil
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .Flame:                return UIColor(hexString: "#e4572e")
            case .CoolGray:             return UIColor(hexString: "#8B8BAE")
            case .Marigold:             return UIColor(hexString: "#F3A712")
            case .GreenMunshell:        return UIColor(hexString: "#00A878")
            case .AirBlue:              return UIColor(hexString: "#669BBC")
            }
        }
        
        public func next() -> Logo {
            switch self {
            case .Flame: return .CoolGray
            case .CoolGray: return .Marigold
            case .Marigold: return .GreenMunshell
            case .GreenMunshell: return .AirBlue
            case .AirBlue: return .Flame
            }
        }
    }
    
    enum Tag: RawRepresentable, CaseIterable {
        typealias RawValue = UIColor
        
        case RoyalPurple
        case PacificBlue
        case LaserLemon
        case CoyoteBrown
        case EnglishVermillion
        case BudGreen
        case Corn
        case Saffron
        case OrangeSoda
        case DarkSlateBlue
        case BleuDeFrance
        case SandyBrown
        case CafeNoir
        case Cardinal
        case GreenPantone
        case HoneyYellow
        case VioletBlueCrayola
        case Avocado
        
        init?(rawValue: RawValue) {
            switch rawValue.toHexString().lowercased() {
            case "#6C4FB2".lowercased(): self = .RoyalPurple
            case "#47A8BD".lowercased(): self = .PacificBlue
            case "#F0F757".lowercased(): self = .LaserLemon
            case "#8F5D35".lowercased(): self = .CoyoteBrown
            case "#D14C57".lowercased(): self = .EnglishVermillion
            case "#72BC71".lowercased(): self = .BudGreen
            case "#F2E86D".lowercased(): self = .Corn
            case "#F8C630".lowercased(): self = .Saffron
            case "#F2542D".lowercased(): self = .OrangeSoda
            case "#4E4187".lowercased(): self = .DarkSlateBlue
            case "#3083DC".lowercased(): self = .BleuDeFrance
            case "#FC9F5B".lowercased(): self = .SandyBrown
            case "#4E3822".lowercased(): self = .CafeNoir
            case "#AD343E".lowercased(): self = .Cardinal
            case "#4DAA57".lowercased(): self = .GreenPantone
            case "#FBB02D".lowercased(): self = .HoneyYellow
            case "#7776BC".lowercased(): self = .VioletBlueCrayola
            case "#5C8001".lowercased(): self = .Avocado
            default: return nil
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .RoyalPurple:          return UIColor(hexString: "#6C4FB2")
            case .PacificBlue:          return UIColor(hexString: "#47A8BD")
            case .LaserLemon:           return UIColor(hexString: "#F0F757")
            case .CoyoteBrown:          return UIColor(hexString: "#8F5D35")
            case .EnglishVermillion:    return UIColor(hexString: "#D14C57")
            case .BudGreen:             return UIColor(hexString: "#72BC71")
            case .Corn:                 return UIColor(hexString: "#F2E86D")
            case .Saffron:              return UIColor(hexString: "#F8C630")
            case .OrangeSoda:           return UIColor(hexString: "#F2542D")
            case .DarkSlateBlue:        return UIColor(hexString: "#4E4187")
            case .BleuDeFrance:         return UIColor(hexString: "#3083DC")
            case .SandyBrown:           return UIColor(hexString: "#FC9F5B")
            case .CafeNoir:             return UIColor(hexString: "#4E3822")
            case .Cardinal:             return UIColor(hexString: "#AD343E")
            case .GreenPantone:         return UIColor(hexString: "#4DAA57")
            case .HoneyYellow:          return UIColor(hexString: "#FBB02D")
            case .VioletBlueCrayola:    return UIColor(hexString: "#7776BC")
            case .Avocado:              return UIColor(hexString: "#5C8001")
            }
        }
        
        public func next() -> Tag {
            switch self {
            case .RoyalPurple: return .PacificBlue
            case .PacificBlue: return .LaserLemon
            case .LaserLemon: return .CoyoteBrown
            case .CoyoteBrown: return .EnglishVermillion
            case .EnglishVermillion: return .BudGreen
            case .BudGreen: return .Corn
            case .Corn: return .Saffron
            case .Saffron: return .OrangeSoda
            case .OrangeSoda: return .DarkSlateBlue
            case .DarkSlateBlue: return .BleuDeFrance
            case .BleuDeFrance: return .SandyBrown
            case .SandyBrown: return .CafeNoir
            case .CafeNoir: return .Cardinal
            case .Cardinal: return .GreenPantone
            case .GreenPantone: return .HoneyYellow
            case .HoneyYellow: return .VioletBlueCrayola
            case .VioletBlueCrayola: return .Avocado
            case .Avocado: return .RoyalPurple
            }
        }
        
        static func all() -> [UIColor] {
            return [
                Tag.GreenPantone.rawValue,
                Tag.EnglishVermillion.rawValue,
                Tag.HoneyYellow.rawValue,
                Tag.RoyalPurple.rawValue,
                Tag.Saffron.rawValue,
                Tag.CoyoteBrown.rawValue,
                Tag.BudGreen.rawValue,
                Tag.PacificBlue.rawValue,
                Tag.LaserLemon.rawValue,
                Tag.Corn.rawValue,
                Tag.Saffron.rawValue,
                Tag.OrangeSoda.rawValue,
                Tag.DarkSlateBlue.rawValue,
                Tag.BleuDeFrance.rawValue,
                Tag.SandyBrown.rawValue,
                Tag.CafeNoir.rawValue,
                Tag.Cardinal.rawValue,
                Tag.VioletBlueCrayola.rawValue,
                Tag.Avocado.rawValue
            ]
        }
    }
  
  static func getColor(forId id: Int) -> UIColor {
    let colors = [
      UIColor(hexString: "#6C4FB2"),
      UIColor(hexString: "#47A8BD"),
      UIColor(hexString: "#8F5D35"),
      UIColor(hexString: "#D14C57"),
      UIColor(hexString: "#72BC71"),
      UIColor(hexString: "#F2E86D"),
      UIColor(hexString: "#F8C630"),
      UIColor(hexString: "#F2542D"),
      UIColor(hexString: "#4E4187"),
      UIColor(hexString: "#3083DC"),
      UIColor(hexString: "#FC9F5B"),
      UIColor(hexString: "#4E3822"),
      UIColor(hexString: "#AD343E"),
      UIColor(hexString: "#4DAA57"),
      UIColor(hexString: "#FBB02D"),
      UIColor(hexString: "#7776BC"),
      UIColor(hexString: "#5C8001"),
      UIColor(hexString: "#F0F757"),
    ]
    
    guard (0...colors.count-1).contains(id) else { return .systemGray }
    
    return colors[id]
  }
}

//extension Color: RawRepresentable {
//    typealias RawValue = UIColor
//
//    init?(rawValue: RawValue) {
//        switch rawValue.toHexString().lowercased() {
//        case "#e4572e".lowercased(): self = .Flame
//        case "#AFC2D5".lowercased(): self = .LightSteelBlue
//        case "#F3A712".lowercased(): self = .Marigold
//        case "#A8C686".lowercased(): self = .Olivine
//        case "#669BBC".lowercased(): self = .AirBlue
//        default: return nil
//        }
//    }
//
//    var rawValue: RawValue {
//        switch self {
//        case .Flame:            return UIColor(hexString: "#e4572e")
//        case .LightSteelBlue:   return UIColor(hexString: "#AFC2D5")
//        case .Marigold:         return UIColor(hexString: "#F3A712")
//        case .Olivine:          return UIColor(hexString: "#A8C686")
//        case .AirBlue:          return UIColor(hexString: "#669BBC")
//        }
//    }
//}
