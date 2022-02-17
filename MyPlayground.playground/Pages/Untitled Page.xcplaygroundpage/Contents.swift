////////
////////  ProgressCirle.swift
////////  ThinkWhat
////////
////////  Created by Pavel Bukharov on 22.10.2019.
////////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////////
//////
////import UIKit
////import PlaygroundSupport
//////
////////extension Float {
////////    var degreesToRadians : CGFloat {
////////        return CGFloat(self) * CGFloat(M_PI) / 180.0
////////    }
////////}
////////
//////////
//////////  ProgressCirle.swift
//////////  ThinkWhat
//////////
//////////  Created by Pavel Bukharov on 22.10.2019.
//////////  Copyright © 2019 Pavel Bukharov. All rights reserved.
//////////
////////extension UIImage {
////////
////////    func circularImage(size: CGSize?, frameColor: UIColor) -> UIImage {
////////        let newSize = size ?? self.size
////////
////////        let minEdge = min(newSize.height, newSize.width)
////////        let size = CGSize(width: minEdge, height: minEdge)
////////
////////        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
////////        let context = UIGraphicsGetCurrentContext()
////////
////////        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
////////
////////        let offset = size.height * 0.04
////////
////////        if frameColor != .clear {
////////            let outerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
////////            outerPath.lineWidth = offset * 2.5
////////            frameColor.setStroke()
////////            outerPath.stroke()
////////
////////            let innerFrame = CGRect(origin: CGPoint(x: CGPoint.zero.x + offset , y: CGPoint.zero.y + offset), size: CGSize(width: size.width - offset * 2, height: size.height - offset * 2))
////////            let innerPath = UIBezierPath(ovalIn: innerFrame)
////////            innerPath.lineWidth = offset * 0.7
////////            UIColor.white.setStroke()
////////            innerPath.stroke()
////////        }
////////
////////        context!.setBlendMode(.copy)
////////        context!.setFillColor(UIColor.clear.cgColor)
////////
////////        let imageSize = size
////////
////////        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: imageSize))
////////        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: imageSize))
////////        rectPath.append(circlePath)
////////        rectPath.usesEvenOddFillRule = true
////////        rectPath.fill()
////////
////////
////////        let result = UIGraphicsGetImageFromCurrentImageContext()
////////        UIGraphicsEndImageContext()
////////
////////        return result!
////////    }
////////
////////}
////////
////////
////////var image = UIImage(named: "user")!
////////let circularImage     = image.circularImage(size: CGSize(width: 200, height: 200), frameColor: .blue)
//////internal class Line {
//////    var path = UIBezierPath()
//////    var layer = CAShapeLayer()
//////}
//////
//////@IBDesignable
//////class BorderedLabel: UILabel {
//////    let line = Line()
//////    var lineWidth: CGFloat = 10
//////    var isAnimated = false
//////
//////    override init(frame: CGRect) {
//////        super.init(frame: frame)
//////        configureLine()
//////    }
//////
//////    required init?(coder aDecoder: NSCoder) {
//////        super.init(coder: aDecoder)
//////        configureLine()
//////    }
//////
//////    func configureLine() {
//////        let path = UIBezierPath()
//////        let point_1 = CGPoint(x: frame.midX - lineWidth / 2, y: frame.minY + lineWidth / 2)
//////        path.move(to: point_1)
//////
//////        let point_2 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.minY + lineWidth / 2)
//////        path.addLine(to: point_2)
//////        let point_3 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.maxY - lineWidth / 2)
//////        path.addLine(to: point_3)
//////        let point_4 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.maxY - lineWidth / 2)
//////        path.addLine(to: point_4)
//////        let point_5 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.minY + lineWidth / 2)
//////        path.addLine(to: point_5)
//////        let point_6 = CGPoint(x: frame.midX + lineWidth / 2, y: frame.minY + lineWidth / 2)
//////        path.addLine(to: point_6)
//////        line.layer.lineWidth = lineWidth
//////        line.layer.strokeColor = UIColor.red.withAlphaComponent(0.2).cgColor
//////        line.layer.fillColor = UIColor.clear.cgColor
//////        line.layer.lineCap = .square
//////        line.layer.path = path.cgPath
//////        line.layer.strokeEnd = isAnimated ? 1 : 0
//////        layer.addSublayer(line.layer)
//////    }
//////
//////    func animate() {
//////        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
//////        strokeEndAnimation.fromValue = line.layer.strokeEnd
//////        strokeEndAnimation.toValue = 1
//////        strokeEndAnimation.duration = 0.5
//////        line.layer.add(strokeEndAnimation, forKey: "animEnd")
//////        isAnimated = true
//////    }
//////}
//////
//////let l = BorderedLabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 150)))
////////l.backgroundColor = .white
//////l.textAlignment = .center
//////l.text = "Test"
//////l.animate()
////////l.configureLine()
////
////let liveView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
////liveView.backgroundColor = .white
////
////PlaygroundPage.current.needsIndefiniteExecution = true
////PlaygroundPage.current.liveView = liveView
////
////let square = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
////square.backgroundColor = .red
////
////liveView.addSubview(square)
////
////let animator = UIViewPropertyAnimator.init(duration: 5, curve: .linear)
////
////animator.addAnimations {
////
////    square.frame.origin.x = 350
////}
////
////let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
////blurView.frame = liveView.bounds
////
////liveView.addSubview(blurView)
////
////animator.addAnimations {
////
////    blurView.effect = nil
////}
////
////// If you want to restore the blur after it was animated, you have to
////// safe a reference to the effect which is manipulated
////let effect = blurView.effect
////
////animator.addCompletion {
////    // In case you want to restore the blur effect
////    if $0 == .start { blurView.effect = effect }
////}
////
////animator.startAnimation()
////animator.pauseAnimation()
////
////DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////
////    animator.fractionComplete = 0.5
////}
////
////DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
////
////    // decide the direction you want your animation to go.
////    // animator.isReversed = true
////    animator.startAnimation()
////}
//
//import UIKit
//
//extension UserDefaults {
//    
//    struct Profile {
//        @UserDefault(key: "id", defaultValue: nil)
//        static var id: Int?
//        
//        @UserDefault(key: "first_тame", defaultValue: nil)
//        static var firstName: String?
//        
//        @UserDefault(key: "last_тame", defaultValue: nil)
//        static var lastName: String?
//        
//        @UserDefault(key: "username", defaultValue: nil)
//        static var username: String?
//        
//        @UserDefault(key: "email", defaultValue: nil)
//        static var email: String?
//        
////        @UserDefault(key: "userImagePath", defaultValue: nil)
////        static var imagePath: String?
//        
//        @UserDefault(key: "birth_date", defaultValue: nil)
//        static var birthDate: Date?
//        
//        @UserDefault(key: "gender", defaultValue: nil)
//        static var gender: String? //          = Gender(rawValue: UserDefaults.standard.string(forKey: "userGender") ?? "") ?? .Unassigned
//            
//        @UserDefault(key: "was_edited", defaultValue: nil)
//        static var wasEdited: Bool?
//        @UserDefault(key: "is_banned", defaultValue: nil)
//        static var isBanned: Bool?
////        @UserDefault(key: "userEmailVerified", defaultValue: nil)
////        static var isEmailVerified: Bool?
//        @UserDefault(key: "imageURL", defaultValue: nil)
//        static var imageURL: String?
//        @UserDefault(key: "instagramURL", defaultValue: nil)
//        static var instagramURL: String?
//        @UserDefault(key: "tiktokURL", defaultValue: nil)
//        static var tiktokURL: String?
//        @UserDefault(key: "vkURL", defaultValue: nil)
//        static var vkURL: String?
//        @UserDefault(key: "facebookURL", defaultValue: nil)
//        static var facebookURL: URL?
//    }
//    
//    @UserDefault(key: "has_seen_app_introduction", defaultValue: false)
//    static var hasSeenAppIntroduction: Bool
//}
//
//import Combine
// 
// @propertyWrapper
// struct UserDefault<Value> {
//     let key: String
//     let defaultValue: Value
//     var container: UserDefaults = .standard
//     private let publisher = PassthroughSubject<Value, Never>()
//     
//     var wrappedValue: Value {
//         get {
//             return container.object(forKey: key) as? Value ?? defaultValue
//         }
//         set {
//             // Check whether we're dealing with an optional and remove the object if the new value is nil.
//             if let optional = newValue as? AnyOptional, optional.isNil {
//                 container.removeObject(forKey: key)
//             } else {
//                 container.set(newValue, forKey: key)
//             }
//             publisher.send(newValue)
//         }
//     }
//
//     var projectedValue: AnyPublisher<Value, Never> {
//         return publisher.eraseToAnyPublisher()
//     }
// }
//
////@propertyWrapper
////struct UserDefaultURL<URL> {
////    let key: String
//////    let defaultValue: URL?
////    var container: UserDefaults = .standard
////
////    var wrappedValue: URL? {
////        get {
//////            return container.url(forKey: key)
////            return container.url(forKey: key) ?? nil
////        }
////        set {
////            container.set(newValue, forKey: key)
////        }
////    }
////}
//
//extension UserDefault where Value: ExpressibleByNilLiteral {
//    
//    /// Creates a new User Defaults property wrapper for the given key.
//    /// - Parameters:
//    ///   - key: The key to use with the user defaults store.
//    init(key: String, _ container: UserDefaults = .standard) {
//        self.init(key: key, defaultValue: nil, container: container)
//    }
//}
//
///// Allows to match for optionals with generics that are defined as non-optional.
//public protocol AnyOptional {
//    /// Returns `true` if `nil`, otherwise `false`.
//    var isNil: Bool { get }
//}
//extension Optional: AnyOptional {
//    public var isNil: Bool { self == nil }
//}
//
//let subscription = UserDefaults.Profile.$username.sink { username in
//    print("New username: \(String(describing: username))")
// }
//
// 
//
//
import UIKit

let locale = NSLocale(localeIdentifier: "ru")
print(locale)

locale.localizedString(forCountryCode: "AF")
//NSLocale.localizedString(forCountryCode: NSLocale(localeIdentifier: "ru"))

extension Bundle {
    static var UIKit: Bundle {
        Self(for: UIApplication.self)
    }
    func localize(_ key: String, table: String? = nil) -> String {
        self.localizedString(forKey: key, value: nil, table: nil)
    }
    var localizableStrings: [String: String]? {
        guard let fileURL = url(forResource: "Localizable", withExtension: "strings") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let plist = try PropertyListSerialization.propertyList(from: data, format: .none)
            return plist as? [String: String]
        } catch {
            print(error)
        }
        return nil
    }
}

Bundle.UIKit.localizableStrings
Bundle.UIKit.localizableStrings?.keys.forEach { print($0)}
