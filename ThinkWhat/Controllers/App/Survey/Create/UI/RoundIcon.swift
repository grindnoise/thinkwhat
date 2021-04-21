////
////  Icon.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 10.03.2021.
////  Copyright © 2021 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class RoundIcon: UIView {
//
////    class func copy(source: RoundIcon) -> RoundIcon {
////
////    }
//
//    override func encode(with aCoder: NSCoder) {
//        aCoder.encode(icon.category.rawValue, forKey: "categoryID")
//        if #available(iOS 11.0, *) {
//            do {
//                let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
//                aCoder.encode(colorData, forKey: "color")
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        aCoder.encode(frame, forKey: "frame")
//        aCoder.encode(icon.text, forKey: "text")
//    }
//
////    let oval: CAShapeLayer
//    var icon: SurveyCategoryIcon! {
//        didSet {
//            addSubview(icon)
//            icon.translatesAutoresizingMaskIntoConstraints = false
//            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//            icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//            icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1.0/1.0).isActive = true
//            icon.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9/1.0).isActive = true
//        }
//    }
//    var color: UIColor = K_COLOR_RED {
//        didSet {
//            backgroundColor = color
//            if icon != nil, icon.isFramed {
//                icon.color = color
//            }
//        }
//    }
//
//    override var frame: CGRect{
//        didSet{
//            cornerRadius = bounds.size.height / 2
//        }
//    }
//
//    override var bounds: CGRect{
//        didSet{
//            cornerRadius = bounds.size.height / 2
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .clear
//        clipsToBounds = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        if let _frame = aDecoder.decodeCGRect(forKey: "frame") as? CGRect,  let colorData = aDecoder.decodeObject(forKey: "color") as? Data, let categoryID = aDecoder.decodeInteger(forKey: "categoryID") as? Int, let text = aDecoder.decodeObject(forKey: "text") as? String {
//            color           = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor ?? K_COLOR_RED
////            oval            = CAShapeLayer()
////            oval.fillColor  = color.cgColor
//            super.init(frame: _frame)
//            self.backgroundColor = color//.clear
////            self.layer.insertSublayer(oval, at: 0)
//            let _icon = getIcon(frame: self.bounds, category: SurveyCategoryIcon.Category(rawValue: categoryID) ?? .Null, color: color, text: text, isFramed: false)
//            addSubview(_icon)
//            _icon.translatesAutoresizingMaskIntoConstraints = false
//            _icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//            _icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//            _icon.heightAnchor.constraint(equalTo: _icon.widthAnchor, multiplier: 1.0/1.0).isActive = true
//            _icon.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9/1.0).isActive = true
//        } else {
//            super.init(coder: aDecoder)
//        }
//    }
//
//}
