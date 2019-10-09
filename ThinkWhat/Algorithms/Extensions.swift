//
//  Extensions.swift
//  Burb
//
//  Created by Pavel Bukharov on 24.03.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SwiftyJSON
//import CTKFlagPhoneNumber
typealias Payload = JSON//[String: AnyObject]


extension UIView {
    
//    class func loadFromNib<T: UIView>() -> T {
//        return T(nibName: String(describing: self), bundle: nil)
//    }
    
    func rotate180Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = (180.0 * CGFloat(Double.pi)) / 180.0 * -1.0
        rotationAnimation.toValue = 0.0
        rotationAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotationAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotationAnimation, forKey: nil)
        
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil, key: String? = nil) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        //rotationAnimation.fromValue = 360.0//(360.0 * CGFloat(M_PI)) / 360.0 * -1.0
        //rotationAnimation.toValue = 0.0
        rotationAnimation.byValue = CGFloat(Double.pi * 2)
        rotationAnimation.duration = duration
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        rotationAnimation.setValue("loading", forKey: "name")
        rotationAnimation.setValue(self, forKey: "view")
        if let delegate: AnyObject = completionDelegate {
            rotationAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotationAnimation, forKey: nil)
        
    }
    
    func fadeTransition(duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        self.layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addEquallyTo(to view: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
//    func layoutCentered(in view: UIView) {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(self)
//        let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
//        let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
//        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0)
//        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
//        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
//    }
    
}

extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {//characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var length: Int {
        return self.count //characters.count
    }
    
//    subscript (i: Int) -> String {
//        return self[Range(i ..< i + 1)]
//    }
//
//    func substring(from: Int) -> String {
//        return self[Range(min(from, length) ..< length)]
//    }
//
//    func substring(to: Int) -> String {
//        return self[Range(0 ..< max(0, to))]
//    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[(start ..< end)])
    }
    
    func toDateTime() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.date(from: self)!
    }
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: self)!
    }
    
    public func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

extension CLLocationCoordinate2D: Hashable {
    public var hashValue: Int {
        get {
            return (latitude.hashValue&*397) &+ longitude.hashValue;
        }
    }
}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension Date {
    init(dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.yyyy"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
    
    init(dateTimeString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateTimeString)!
        self.init(timeInterval:0, since:d)
    }
    
    func toDateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func toDateTimeStringWithoutSeconds() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, HH:mm"
        return formatter.string(from: self)
    }
    
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}

extension NSLayoutConstraint {

    func setMultiplier(_ multiplier:CGFloat, duration: Double = 0) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        UIView.animate(withDuration: duration, animations: {
            (self.firstItem as? UIView)?.alpha = 0
        }, completion: {
            _ in
            NSLayoutConstraint.deactivate([self])
            NSLayoutConstraint.activate([newConstraint])
        })
        
//        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
//            (self.firstItem as? UIView)?.alpha = 1
//        }, completion: nil)
        
        return newConstraint
    }
}

extension UIViewController {
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
}

extension UIImage {
    
    func circularImage(size: CGSize?) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
        
        let offset = size.height * 0.03
        
        let outerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        outerPath.lineWidth = offset * 2
        K_COLOR_RED.setStroke()
        outerPath.stroke()
        
        let innerFrame = CGRect(origin: CGPoint(x: CGPoint.zero.x + offset, y: CGPoint.zero.y + offset), size: CGSize(width: size.width - offset * 2, height: size.height - offset * 2))
        let innerPath = UIBezierPath(ovalIn: innerFrame)
        innerPath.lineWidth = offset
        UIColor.white.setStroke()
        innerPath.stroke()
        
        context!.setBlendMode(.copy)
        context!.setFillColor(UIColor.clear.cgColor)
        
        let imageSize = size
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: imageSize))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: imageSize))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
}

extension UISearchBar {
    func changeSearchBarColor(color : UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if let _ = subSubView as? UITextInputTraits {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
    
    func changeSearchBarFont(_ fontName: String, fontSize: CGFloat) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if let _ = subSubView as? UITextInputTraits {
                    let textField = subSubView as! UITextField
                    textField.font = UIFont(name: fontName, size: fontSize)
                    break
                }
            }
        }
    }
}

extension UIView {
    func copyView<T: UIView>() -> T? {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? T
    }
    
    func makeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }
}

public extension CABasicAnimation {
    convenience init(path: String, fromValue: Any?, toValue: Any?, duration: CFTimeInterval) {
        self.init(keyPath: path)
        
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        isRemovedOnCompletion = false
        fillMode = CAMediaTimingFillMode.forwards
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

extension NSData{
    var fileFormat: FileFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else if buffer == ImageHeaderData.GIF
        {
            return .GIF
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else{
            return .Unknown
        }
    }
}
//extension Bool {
//    init<T: Integer>(_ num: T) {
//        self.init(num != 0)
//    }
//}


//extension CustomNavigationController : UINavigationBarDelegate {
//    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
//        return false
//    }
//}

//extension Dictionary where Key == String {
//    mutating func nestDictionary(_ dictionaryName: String, dictionary: [String : Any]) -> Dictionary {
//        self[dictionaryName] = dictionary as! Value
//        return self
//    }
//}
