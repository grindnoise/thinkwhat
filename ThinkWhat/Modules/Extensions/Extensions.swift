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
    rotationAnimation.fromValue = 0.0
    rotationAnimation.toValue = M_PI
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
  
  
  
  
  func animateMaskLayer(duration: TimeInterval, completionBlocks: [Closure], completionDelegate: CAAnimationDelegate?) {
    
    let circlePathLayer = CAShapeLayer()
    
    func circleFrameTopCenter() -> CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    func circleFrameTop() -> CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
      return UIBezierPath(ovalIn: circleFrameTopCenter())
    }
    
    circlePathLayer.frame = self.bounds
    circlePathLayer.path = circlePath().cgPath
    self.layer.mask = circlePathLayer
    self.alpha = 1
    
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    
    let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
    
    let radiusInset = finalRadius
    
    let outerRect = circleFrameTop().insetBy(dx: -radiusInset, dy: -radiusInset)
    
    let toPath = UIBezierPath(ovalIn: outerRect).cgPath
    
    let fromPath = circlePathLayer.path
    
    let maskLayerAnimation = CABasicAnimation(keyPath: "path")
    
    maskLayerAnimation.fromValue = fromPath
    maskLayerAnimation.toValue = toPath
    maskLayerAnimation.duration = duration
    maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    maskLayerAnimation.isRemovedOnCompletion = true
    if completionDelegate != nil {
      maskLayerAnimation.delegate = completionDelegate
      //Remove mask
      var blocks: [Closure] = []
      blocks += completionBlocks
      blocks.append {
        DispatchQueue.main.async {
          circlePathLayer.removeFromSuperlayer()
        }
      }
      maskLayerAnimation.setValue(blocks, forKey: "maskCompletionBlocks")
    }
    circlePathLayer.add(maskLayerAnimation, forKey: "path")
    circlePathLayer.path = toPath
  }
  
  func animateCircleLayer(shapeLayer: CAShapeLayer, reveal: Bool, duration: TimeInterval, completionBlocks: [Closure], completionDelegate: CAAnimationDelegate?) {
    self.layer.masksToBounds = true
    
    func circleFrameTopCenter() -> CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = shapeLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    func circleFrameTop() -> CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = shapeLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
      return UIBezierPath(ovalIn: circleFrameTopCenter())
    }
    
    shapeLayer.frame = self.bounds
    //        let startPath = circlePath().cgPath
    //        shapeLayer.path = reveal ? startPath : //circlePath().cgPath
    //        self.layer.insertSublayer(shapeLayer, at: 0)
    //        self.layer.mask = circlePathLayer
    //        self.alpha = 1
    
    let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    
    let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
    
    let radiusInset = finalRadius
    
    let outerRect = circleFrameTop().insetBy(dx: -radiusInset, dy: -radiusInset)
    
    let fromPath = UIBezierPath(ovalIn: outerRect).cgPath
    
    let toPath = shapeLayer.path
    
    let startPath = circlePath().cgPath
    shapeLayer.path = reveal ? startPath : fromPath//circlePath().cgPath
    
    let maskLayerAnimation = CABasicAnimation(keyPath: "path")
    
    maskLayerAnimation.fromValue = reveal ? startPath : fromPath//startPath//fromPath
    maskLayerAnimation.toValue = !reveal ? startPath : fromPath//fromPath//toPath
    maskLayerAnimation.duration = duration
    maskLayerAnimation.fillMode = .forwards
    maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    maskLayerAnimation.isRemovedOnCompletion = true
    
    if completionDelegate != nil {
      var blocks: [Closure] = []
      blocks += completionBlocks
      maskLayerAnimation.delegate = completionDelegate
      maskLayerAnimation.setValue(blocks, forKey: "circleLayerAnimCompletionBlocks")
      maskLayerAnimation.setValue(shapeLayer, forKey: reveal ? "preserveLayer" : "removeLayer")
    }
    
    shapeLayer.add(maskLayerAnimation, forKey: nil)
    shapeLayer.path = !reveal ? startPath : fromPath//fromPath//toPath
    
  }
  
  func getAllConstraints() -> [NSLayoutConstraint] {
    var views = [self]
    
    var view = self
    while let superview = view.superview {
      views.append(superview)
      view = superview
    }
    
    return views.flatMap({ $0.constraints }).filter { constraint in
      return constraint.firstItem as? UIView == self ||
      constraint.secondItem as? UIView == self
    }
  }
  
  func getConstraint(identifier: String) -> NSLayoutConstraint? {
    return self.getAllConstraints().filter({ $0.identifier == identifier }).first
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

extension Dictionary where Value: Equatable {
  func allKeys(forValue val: Value) -> [Key] {
    return self.filter { $1 == val }.map { $0.0 }
  }
}

extension CGFloat {
  var degreesToRadians: CGFloat { return self * .pi / 180 }
  var radiansToDegrees: CGFloat { return self * 180 / .pi }
  
  func toRadians() -> CGFloat {
    return self * CGFloat(Double.pi) / 180.0
  }
}



extension UIViewController {
  class func loadFromNib<T: UIViewController>() -> T {
    return T(nibName: String(describing: self), bundle: nil)
  }
}

extension UIImage {
  
  func circularImage(size: CGSize?, frameColor: UIColor) -> UIImage {
    let newSize = size ?? self.size
    
    let minEdge = min(newSize.height, newSize.width)
    let size = CGSize(width: minEdge, height: minEdge)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
    
    let offset = size.height * 0.04
    
    let outerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
    outerPath.lineWidth = offset * 2.5
    UIColor.white.setStroke()
    outerPath.stroke()
    
    if frameColor != .clear {
      let outerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
      outerPath.lineWidth = offset * 2.5
      frameColor.setStroke()
      outerPath.stroke()
      
      //            let innerFrame = CGRect(origin: CGPoint(x: CGPoint.zero.x + offset , y: CGPoint.zero.y + offset), size: CGSize(width: size.width - offset * 2, height: size.height - offset * 2))
      //            let innerPath = UIBezierPath(ovalIn: innerFrame)
      //            innerPath.lineWidth = offset * 0.7
      //            UIColor.white.setStroke()
      //            innerPath.stroke()
    }
    
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
  
  func colored(in color: UIColor) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    let renderedImage = renderer.image { _ in
      color.set()
      self.withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
    }
    
    return renderedImage
  }
  
  @available(iOS 15, *)
  var thumbnail: UIImage? {
    get async {
      let size = CGSize(width: 80, height: 40)
      return await self.byPreparingThumbnail(ofSize: size)
    }
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
  
  func scrollToBottom() {
    if text.count > 0 {
      let location = text.count - 1
      let bottom = NSMakeRange(location, 1)
      scrollRangeToVisible(bottom)
    }
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

extension UIImage {
  class func colorForNavBar(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1)
    //    Or if you need a thinner border :
    //    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
  
  var jpeg: Data? {
    return jpegData(compressionQuality: 1)   // QUALITY min = 0 / max = 1
  }
  var png: Data? {
    return pngData()
  }
  
  func resized(to size: CGSize) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
  }
  
  func isEqualToImage(image: UIImage) -> Bool {
    let data1: NSData = self.pngData()! as NSData
    let data2: NSData = image.pngData()! as NSData
    return data1.isEqual(data2)
  }
}

extension Float {
  var degreesToRadians : CGFloat {
    return CGFloat(self) * CGFloat(Double.pi) / 180.0
  }
}

extension Int {
  var stringValue: String? {
    if self != nil {
      return "\(self)"
    }
    return nil
  }
}

extension Array where Element: Equatable {
  mutating func remove(object: Element) {
    guard let index = index(of: object) else {return}
    remove(at: index)
  }
  
  mutating func addUnique(object: Element) {
    guard index(of: object) != nil else {return}
    append(object)
  }
}

extension UIDevice {
  func isJailBroken() -> Bool {
    if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
        || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
        || FileManager.default.fileExists(atPath: "/bin/bash")
        || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
        || FileManager.default.fileExists(atPath: "/etc/apt")
        || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
        || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!) {
      return true
    }
    // Check 2 : Reading and writing in system directories (sandbox violation)
    let stringToWrite = "Jailbreak Test"
    do {
      try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
      //Device is jailbroken
      return true
    } catch {
      return false
    }
  }
}

extension UITabBarController {
  
  private struct AssociatedKeys {
    // Declare a global var to produce a unique address as the assoc object handle
    static var orgFrameView:     UInt8 = 0
    static var movedFrameView:   UInt8 = 1
  }
  
  var orgFrameView:CGRect? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.orgFrameView) as? CGRect }
    set { objc_setAssociatedObject(self, &AssociatedKeys.orgFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
  }
  
  var movedFrameView:CGRect? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.movedFrameView) as? CGRect }
    set { objc_setAssociatedObject(self, &AssociatedKeys.movedFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
  }
  
  override open func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if let movedFrameView = movedFrameView {
      view.frame = movedFrameView
    }
  }
  
  func setTabBarVisible(visible:Bool, animated:Bool) {
    
    var bottomSafeArea = CGFloat.zero
    //        if let window = UIApplication.shared.windows.first,
    //              let bottom = window.safeAreaInsets.bottom as? CGFloat
    //         { bottomSafeArea = bottom }
    
    
    //                view.backgroundColor =  self.tabBar.barTintColor
    //        if (tabBarIsVisible() == visible) { return }
    //                let frame = self.tabBar.frame
    //                let height = frame.size.height
    //                let offsetY = (visible ? -height : height)
    //
    //                // animation
    //        UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
    //                    self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
    //                    self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
    //                    self.view.setNeedsDisplay()
    //                    self.view.layoutIfNeeded()
    //                }.startAnimation()
    //since iOS11 we have to set the background colour to the bar color it seams the navbar seams to get smaller during animation; this visually hides the top empty space...
    view.backgroundColor =  self.tabBar.barTintColor
    // bail if the current state matches the desired state
    if (tabBarIsVisible() == visible) { return }
    
    //we should show it
    if visible {
      //            self.tabBar.alpha = 0
      let offsetY = self.tabBar.frame.size.height
      movedFrameView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)// + offsetY + bottomSafeArea)
      self.view.frame = self.movedFrameView!
      tabBar.isHidden = false
      isTabBarHidden = false
      //                            self.view.setNeedsDisplay()
      //            self.view.layoutIfNeeded()
      //            self.view.setNeedsLayout()
      UIView.animate(withDuration: animated ? 0.225 : 0.0) {
        //restore form or frames
        
        self.view.frame = self.orgFrameView!
        //errase the stored locations so that...
        //                self.tabBar.alpha = 1
        self.orgFrameView = nil
        self.movedFrameView = nil
        //...the layoutIfNeeded() does not move them again!
        //                self.view.layoutSubviews()
        //                self.view.setNeedsDisplay()
        //
        //                self.view.layoutIfNeeded()
        //                self.edgesForExtendedLayout = UIRectEdge.bottom
        //                self.extendedLayoutIncludesOpaqueBars = true
      }
    }
    //we should hide it
    else {
      //safe org positions
      orgFrameView   = view.frame
      // get a frame calculation ready
      let offsetY = self.tabBar.frame.size.height
      movedFrameView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY - bottomSafeArea)
      //animate
      UIView.animate(withDuration: animated ? 0.225 : 0.0, animations: {
        //                self.tabBar.alpha = 0
        self.view.frame = self.movedFrameView!
        //                self.view.setNeedsDisplay()
        //                self.view.layoutIfNeeded()
      }) { _ in
        self.tabBar.isHidden = true
        isTabBarHidden = true
        //                self.tabBar.alpha = 1
        //                self.movedFrameView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY + 30)
        //                self.view.frame = self.movedFrameView!
        //                self.edgesForExtendedLayout = UIRectEdge.bottom
        //                self.extendedLayoutIncludesOpaqueBars = true
      }
    }
  }
  
  func tabBarIsVisible() ->Bool {
    //        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
    return orgFrameView == nil
  }
}

extension UITextField {
  func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
    let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
    let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
    
    let toolbar: UIToolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.tintColor = K_COLOR_RED
    toolbar.items = [
      UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
      UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
    ]
    toolbar.sizeToFit()
    
    self.inputAccessoryView = toolbar
  }
  
  // Default actions:
  @objc func doneButtonTapped() { delegate?.textFieldShouldReturn!(self) }
  @objc func cancelButtonTapped() { self.resignFirstResponder() }
  
}

extension RangeReplaceableCollection where Indices: Equatable {
  mutating func rearrange(from: Index, to: Index) {
    //        if from != to {
    precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indices")
    insert(remove(at: from), at: to)
    //        }
  }
}



extension UIColor {
  convenience init(hexString: String, alpha: CGFloat = 1.0) {
    let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }
    var color: UInt32 = 0
    scanner.scanHexInt32(&color)
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    let red   = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue  = CGFloat(b) / 255.0
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
  
  func toHexString() -> String {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    return String(format:"#%06x", rgb)
  }
  
  var hex: String {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    return String(format:"#%06x", rgb)
  }
  
  func withLuminosity(_ newLuminosity: CGFloat) -> UIColor {
    // 1 - Convert the RGB values to the range 0-1
    let coreColour = CIColor(color: self)
    var red = coreColour.red
    var green = coreColour.green
    var blue = coreColour.blue
    let alpha = coreColour.alpha
    
    // 1a - Normalise these colours between 0 and 1 (combat sRGB colour space)
    red = red.normalise(min: 0, max: 1)
    green = green.normalise(min: 0, max: 1)
    blue = blue.normalise(min: 0, max: 1)
    
    // 2 - Find the minimum and maximum values of R, G and B.
    guard let minRGB = [red, green, blue].min(), let maxRGB = [red, green, blue].max() else {
      return self
    }
    
    // 3 - Now calculate the Luminace value by adding the max and min values and divide by 2.
    var luminosity = (minRGB + maxRGB) / 2
    
    // 4 - The next step is to find the Saturation.
    // 4a - if min and max RGB are the same, we have 0 saturation
    var saturation: CGFloat = 0
    
    // 5 - Now we know that there is Saturation we need to do check the level of the Luminance in order to select the correct formula.
    //     If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
    //     If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
    if luminosity < 0.5 {
      saturation = (maxRGB - minRGB)/(maxRGB + minRGB)
    } else if luminosity > 0.5 {
      saturation = (maxRGB - minRGB)/(2.0 - maxRGB - minRGB)
    } else {
      // 0 if we are equal RGBs
    }
    
    // 6 - The Hue formula is depending on what RGB color channel is the max value. The three different formulas are:
    var hue: CGFloat = 0
    // 6a - If Red is max, then Hue = (G-B)/(max-min)
    if red == maxRGB {
      hue = (green - blue) / (maxRGB - minRGB)
    }
    // 6b - If Green is max, then Hue = 2.0 + (B-R)/(max-min)
    else if green == maxRGB {
      hue = 2.0 + ((blue - red) / (maxRGB - minRGB))
    }
    // 6c - If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
    else if blue == maxRGB {
      hue = 4.0 + ((red - green) / (maxRGB - minRGB))
    }
    
    // 7 - The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
    //     If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
    if hue < 0 {
      hue += 360
    } else {
      hue = hue * 60
    }
    
    // we want to convert the luminosity. So we will.
    luminosity = newLuminosity
    
    // Now we need to convert back to RGB
    
    // 1 - If there is no Saturation it means that it’s a shade of grey. So in that case we just need to convert the Luminance and set R,G and B to that level.
    if saturation == 0 {
      return UIColor(red: 255 * luminosity, green: 255 * luminosity, blue: 255 * luminosity, alpha: alpha)
    }
    
    // 2 - If Luminance is smaller then 0.5 (50%) then temporary_1 = Luminance x (1.0+Saturation)
    //     If Luminance is equal or larger then 0.5 (50%) then temporary_1 = Luminance + Saturation – Luminance x Saturation
    var temporaryVariableOne: CGFloat = 0
    if luminosity < 0.5 {
      temporaryVariableOne = luminosity * (1 + saturation)
    } else {
      temporaryVariableOne = luminosity + saturation - luminosity * saturation
    }
    
    // 3 - Final calculated temporary variable
    let temporaryVariableTwo = 2 * luminosity - temporaryVariableOne
    
    // 4 - The next step is to convert the 360 degrees in a circle to 1 by dividing the angle by 360
    let convertedHue = hue / 360
    
    // 5 - Now we need a temporary variable for each colour channel
    let tempRed = (convertedHue + 0.333).convertToColourChannel()
    let tempGreen = convertedHue.convertToColourChannel()
    let tempBlue = (convertedHue - 0.333).convertToColourChannel()
    
    // 6 we must run up to 3 tests to select the correct formula for each colour channel, converting to RGB
    let newRed = tempRed.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
    let newGreen = tempGreen.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
    let newBlue = tempBlue.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
    
    return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
  }
  
  func lighter(_ amount : CGFloat = 0.25) -> UIColor {
    return hueColorWithBrightnessAmount(amount: 1 + amount)
  }
  
  func darker(_ amount : CGFloat = 0.25) -> UIColor {
    return hueColorWithBrightnessAmount(amount: 1 - amount)
  }
  
  private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
    var hue         : CGFloat = 0
    var saturation  : CGFloat = 0
    var brightness  : CGFloat = 0
    var alpha       : CGFloat = 0
    
#if os(iOS)
    
    if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
      return UIColor( hue: hue,
                      saturation: saturation,
                      brightness: brightness * amount,
                      alpha: alpha )
    } else {
      return self
    }
    
#else
    
    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return UIColor( hue: hue,
                    saturation: saturation,
                    brightness: brightness * amount,
                    alpha: alpha )
    
#endif
    
  }
}

fileprivate extension CGFloat {
  /// Normalise the supplied value between a min and max
  /// - Parameter min: The min value
  /// - Parameter max: The max value
  func normalise(min: CGFloat, max: CGFloat) -> CGFloat {
    if self < min {
      return min
    } else if self > max {
      return max
    } else {
      return self
    }
  }
  
  /// If colour value is less than 1, add 1 to it. If temp colour value is greater than 1, substract 1 from it
  func convertToColourChannel() -> CGFloat {
    let min: CGFloat = 0
    let max: CGFloat = 1
    let modifier: CGFloat = 1
    if self < min {
      return self + modifier
    } else if self > max {
      return self - max
    } else {
      return self
    }
  }
  
  /// Formula to convert the calculated colour from colour multipliers
  /// - Parameter temp1: Temp variable one (calculated from luminosity)
  /// - Parameter temp2: Temp variable two (calcualted from temp1 and luminosity)
  func convertToRGB(temp1: CGFloat, temp2: CGFloat) -> CGFloat {
    if 6 * self < 1 {
      return temp2 + (temp1 - temp2) * 6 * self
    } else if 2 * self < 1 {
      return temp1
    } else if 3 * self < 2 {
      return temp2 + (temp1 - temp2) * (0.666 - self) * 6
    } else {
      return temp2
    }
  }
  
  
}
extension CGSize {
  static func > (left: CGSize, right: CGSize) -> Bool {
    return left.width * left.height > right.width * right.height
  }
}

extension CGPath {
  func getScaledPath(size: CGSize, scaleMultiplicator _scaleMultiplicator: CGFloat = 0) -> CGPath {
    
    let boundingBox = self.boundingBox
    
    let boundingBoxAspectRatio = boundingBox.width/boundingBox.height
    let viewAspectRatio = size.width/size.height
    
    var scaleFactor: CGFloat = 1.0
    if (boundingBoxAspectRatio > viewAspectRatio) {
      
      // Width is limiting factor
      scaleFactor = size.width/boundingBox.width
    } else {
      // Height is limiting factor
      scaleFactor = size.height/boundingBox.height
    }
    
    scaleFactor /= _scaleMultiplicator != 0 ? _scaleMultiplicator : 2.05
    scaleFactor = scaleFactor == 0 ? 1 : scaleFactor
    //
    //        if _scaleMultiplicator != 1 {
    //            scaleFactor = _scaleMultiplicator
    //        }
    // Scaling the path ...
    var scaleTransform = CGAffineTransform.identity
    // Scale down the path first
    scaleTransform = scaleTransform.scaledBy(x: scaleFactor, y: scaleFactor);
    // Then translate the path to the upper left corner
    scaleTransform = scaleTransform.translatedBy(x: -boundingBox.minX, y: -boundingBox.minY);
    
    // If you want to be fancy you could also center the path in the view
    // i.e. if you don't want it to stick to the top.
    // It is done by calculating the heigth and width difference and translating
    // half the scaled value of that in both x and y (the scaled side will be 0)
    let scaledSize = boundingBox.size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
    
    let centerOffset = CGSize(width: (size.width-scaledSize.width)/(scaleFactor*2.0), height: (size.height-scaledSize.height)/(scaleFactor*2.0))
    scaleTransform = scaleTransform.translatedBy(x: centerOffset.width, y: centerOffset.height);
    // End of "center in view" transformation code
    
    let scaledPath = self.copy(using: &scaleTransform)
    return scaledPath!
  }
}

extension UIImageView {
  func getImageRect() -> CGRect {
    let imageViewSize = frame.size
    let imgSize = image?.size
    
    guard let imageSize = imgSize else {
      return CGRect.zero
    }
    
    let scaleWidth = imageViewSize.width / imageSize.width
    let scaleHeight = imageViewSize.height / imageSize.height
    let aspect = fmin(scaleWidth, scaleHeight)
    
    var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
    // Center image
    imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
    imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
    
    // Add imageView offset
    imageRect.origin.x += frame.origin.x
    imageRect.origin.y += frame.origin.y
    
    return imageRect
  }
}
extension CAShapeLayer {
  func copyLayer() -> CAShapeLayer {
    return CAShapeLayer(layer: self)
  }
}

extension CGPoint {
  static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
    let x = center.x + radius * cos(angle)
    let y = center.y + radius * sin(angle)
    
    return CGPoint(x: x, y: y)
  }
}

extension Formatter {
  static let withSeparator: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    return formatter
  }()
}

extension Numeric {
  var formattedWithSeparator: String { return Formatter.withSeparator.string(for: self) ?? "" }
}

extension UIApplication {
  var statusBarView: UIView? {
    if #available(iOS 13.0, *) {
      //TODO: - Uncomment
      let tag = 38482
      let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
      
      if let statusBar = keyWindow?.viewWithTag(tag) {
        return statusBar
      } else {
        guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.tag = tag
        keyWindow?.addSubview(statusBarView)
        return statusBarView
      }
    } else if responds(to: Selector(("statusBar"))) {
      return value(forKey: "statusBar") as? UIView
    }
    return nil
  }
}

//extension UINavigationController {
//    override open var childForStatusBarStyle: UIViewController? {
//        return topViewController
//    }
//
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        return topViewController?.preferredStatusBarStyle ?? .default
//    }
//}
public extension CollectionCellAutoLayout where Self: UICollectionViewCell {
  func preferredLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    setNeedsLayout()
    layoutIfNeeded()
    let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
    var newFrame = layoutAttributes.frame
    newFrame.size.width = CGFloat(ceilf(Float(size.width)))
    newFrame.size.height = size.height
    layoutAttributes.frame = newFrame
    cachedSize = newFrame.size
    return layoutAttributes
  }
}

extension Sequence where Element: Hashable {
  func uniqued() -> [Element] {
    var set = Set<Element>()
    return filter { set.insert($0).inserted }
  }
}

/// Easily throw generic errors with a text description.
extension String: Error { }

extension UIView {
  /// Eventhough we already set the file owner in the xib file, where we are setting the file owner again because sending nil will set existing file owner to nil.
  @discardableResult
  func fromNib<T : UIView>() -> T? {
    guard let contentView = Bundle(for: type(of: self))
      .loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
      return nil
    }
    return contentView
  }
}

extension JSON{
  mutating func appendIfArray(json:JSON){
    if var arr = self.array{
      arr.append(json)
      self = JSON(arr);
    }
  }
  
  mutating func appendIfDictionary(key:String,json:JSON){
    if var dict = self.dictionary{
      dict[key] = json;
      self = JSON(dict);
    }
  }
}

extension JSONDecoder {
  
  /// Assign multiple DateFormatter to dateDecodingStrategy
  ///
  /// Usage :
  ///
  ///      decoder.dateDecodingStrategyFormatters = [ DateFormatter.standard, DateFormatter.yearMonthDay ]
  ///
  /// The decoder will now be able to decode two DateFormat, the 'standard' one and the 'yearMonthDay'
  ///
  /// Throws a 'DecodingError.dataCorruptedError' if an unsupported date format is found while parsing the document
  var dateDecodingStrategyFormatters: [DateFormatter]? {
    @available(*, unavailable, message: "This variable is meant to be set only")
    get { return nil }
    set {
      guard let formatters = newValue else { return }
      self.dateDecodingStrategy = .custom { decoder in
        
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        for formatter in formatters {
          if let date = formatter.date(from: dateString) {
            return date
          }
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
      }
    }
  }
}





/**
 Returns a localized plural version of the string designated by the specified `key` and residing in `resource`.
 - parameter key: The key for a string in resource.
 - parameter resource: The receiver’s string resource to search. If resource is nil or is an empty string, the method attempts to use the resource in **Localizable** files.
 - parameter fittingWidth: The desired width of the string variation.
 - parameter arg: The values for which the appropriate plural form is selected.
 - parameter converting: A closure used to modify the number to display it to the user.
 - returns: A localized plural version of the string designated by `key`. This method returns `key` when `key` not found or `arg` is not a number .
 */
extension String {
  func localized(forLanguageCode lanCode: String) -> String {
    guard
      let bundlePath = Bundle.main.path(forResource: lanCode, ofType: "lproj"),
      let bundle = Bundle(path: bundlePath)
    else { return "" }
    
    return NSLocalizedString(
      self,
      bundle: bundle,
      value: " ",
      comment: ""
    )
  }
}
