//
//  Animations.swift
//  MapRiddle
//
//  Created by Pavel Bukharov on 12.07.17.
//  Copyright © 2017 Pavel Bukharov. All rights reserved.
//

import UIKit
import MapKit

struct Animations {
  
  struct Duration {
    static let percentageStroke = 0.75
  }
  
  enum AnimationProperty: String {
    case FillColor       = "fillColor"
    case ShadowPath      = "shadowPath"
    case ShadowOpacity   = "shadowOpacity"
    case Scale           = "transform.scale"
    case ScaleY          = "transform.scale.Y"
    case Path            = "path"
    case Rotation        = "transform.rotation.z"
    case BackgroundColor = "backgroundColor"
    case StrokeStart     = "strokeStart"
    case StrokeEnd       = "strokeEnd"
    case StrokeColor     = "strokeColor"
    case LineWidth       = "lineWidth"
    case Opacity         = "opacity"
    case Colors          = "colors"
    case Locations       = "locations"
    case Transform       = "transform"
  }
  static func group(animations: [CAAnimation], repeatCount: Float = 0, autoreverses: Bool = false, duration: CFTimeInterval, delay beginTime: CFTimeInterval = 0.0, timingFunction: CAMediaTimingFunctionName = CAMediaTimingFunctionName.default, delegate: CAAnimationDelegate?, isRemovedOnCompletion: Bool = true) -> CAAnimationGroup {
    
    let anim = CAAnimationGroup()
    anim.animations = animations
    anim.duration = duration
    anim.beginTime = CACurrentMediaTime() + beginTime
    anim.timingFunction = CAMediaTimingFunction(name: timingFunction)
    anim.repeatCount = repeatCount
    anim.delegate = delegate
    anim.autoreverses = autoreverses
    anim.delegate = delegate
    anim.isRemovedOnCompletion = isRemovedOnCompletion
    //        anim.fillMode = .forwards
    return anim
    
  }
  
  static func get(property: AnimationProperty,
                  fromValue: Any,
                  toValue: Any,
                  duration: CFTimeInterval,
                  delay beginTime: CFTimeInterval = 0.0,
                  repeatCount: Float = 0,
                  autoreverses: Bool = false,
                  fillMode: CAMediaTimingFillMode = .forwards,
                  timingFunction: CAMediaTimingFunctionName = CAMediaTimingFunctionName.default,
                  delegate: CAAnimationDelegate? = nil,
                  isRemovedOnCompletion: Bool = true,
                  completionBlocks: [Closure]? = nil,
                  delay: CFTimeInterval = 0.0) -> CAAnimation {
    
    let anim = CABasicAnimation(keyPath: property.rawValue)
    anim.beginTime = CACurrentMediaTime() + delay
    anim.fromValue = fromValue
    anim.toValue = toValue
    anim.duration = duration
    anim.beginTime = CACurrentMediaTime() + beginTime
    anim.repeatCount = repeatCount
    anim.autoreverses = autoreverses
    anim.fillMode = CAMediaTimingFillMode.forwards
    anim.isRemovedOnCompletion = isRemovedOnCompletion
    if delegate != nil {
      anim.delegate = delegate!
      anim.setValue(completionBlocks, forKey: "completionBlocks")
    }
    anim.timingFunction = CAMediaTimingFunction(name: timingFunction)
    
    return anim
  }
  
  static func fadeInFadeOut(layer: CALayer, fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval, delay beginTime: CFTimeInterval = 0.0, timingFunction: CAMediaTimingFunctionName = CAMediaTimingFunctionName.default, keyValue: String = "", isRemovedOnCompletion: Bool = true) -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath: "opacity")//анимируемое свойство
    anim.fromValue = fromValue//стартовое значение
    anim.toValue = toValue//конечное значение
    anim.duration = duration//длительность
    anim.beginTime = CACurrentMediaTime() + beginTime//время начала (берем текущее время и прибавляем задержку, если необходимо)
    anim.isRemovedOnCompletion = isRemovedOnCompletion
    anim.timingFunction = CAMediaTimingFunction(name: timingFunction)//темп анимации (быстрое начало и медленное завершение, медленное начало и быстрое завершение и тд)
    anim.setValue(keyValue, forKey: "name")//добавляем характеристики
    anim.setValue(layer, forKey: "layer")
    //anim.delegate = self//делегат для выполнения протокола
    return anim
    
  }
  
  static func rotate360(layer: CALayer, duration: CFTimeInterval = 1.0, keyValue: String? = nil) -> CABasicAnimation {
    
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    //rotationAnimation.fromValue = 360.0//(360.0 * CGFloat(M_PI)) / 360.0 * -1.0
    //rotationAnimation.toValue = 0.0
    rotationAnimation.byValue = CGFloat(Double.pi * 2)
    rotationAnimation.duration = duration
    //rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    rotationAnimation.setValue(keyValue, forKey: "name")
    rotationAnimation.setValue(layer, forKey: "layer")
    //rotationAnimation.delegate = self
    return rotationAnimation
  }
  
  static func changeImageCrossDissolve(imageView: UIImageView, image: UIImage, duration: TimeInterval = 0.5, animations: [Closure] = []) {
    Task {
      await MainActor.run {
        UIView.transition(with: imageView,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
          imageView.image = image
          animations.forEach { $0() }
        })
      }
    }
  }
  
  static func unmaskCircled(view animatedView: UIView,
                            location: CGPoint,
                            duration: TimeInterval,
                            animateOpacity: Bool = true,
                            opacityDurationMultiplier: Double = 1,
                            delegate: CAAnimationDelegate,
                            completionBlocks: [Closure] = []) {
    
    let circlePathLayer = CAShapeLayer()
    var _completionBlocks = completionBlocks
    var circleFrameTopCenter: CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
      return circleFrame
    }
    
    var circleFrameTop: CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    var circleFrameTopLeft: CGRect {
      return CGRect.zero
    }
    
    var circleFrameTouchPosition: CGRect {
      return CGRect(origin: location, size: .zero)
    }
    
    var circleFrameCenter: CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    func circlePath(_ rect: CGRect) -> UIBezierPath {
      return UIBezierPath(ovalIn: rect)
    }
    
    circlePathLayer.frame = animatedView.bounds
    circlePathLayer.path = circlePath(circleFrameTouchPosition).cgPath
    animatedView.layer.mask = circlePathLayer
    
    //        let center = lastPoint//(x: animatedView.bounds.midX, y: animatedView.bounds.midY)
    
    let finalRadius = max(abs(animatedView.bounds.width - location.x),
                          abs(animatedView.bounds.width - (animatedView.bounds.width - location.x)))//sqrt((center.x*center.x) + (center.y*center.y))
    
    let radiusInset = finalRadius * 1.5
    
    let outerRect = circleFrameTouchPosition.insetBy(dx: -radiusInset, dy: -radiusInset)
    
    let toPath = UIBezierPath(ovalIn: outerRect).cgPath
    
    let fromPath = circlePathLayer.path
    
    let anim = Animations.get(property: .Path,
                              fromValue: fromPath as Any,
                              toValue: toPath,
                              duration: duration,
                              delay: 0,
                              repeatCount: 0,
                              autoreverses: false,
                              timingFunction: .easeOut,
                              delegate: delegate,
                              isRemovedOnCompletion: true,
                              completionBlocks: [])
    
    circlePathLayer.add(anim, forKey: "path")
    circlePathLayer.path = toPath
   
    guard animateOpacity else { return }
    animatedView.alpha = 1
    animatedView.layer.opacity = 0
    let opacityAnim = Animations.get(property: .Opacity,
                                     fromValue: 0,
                                     toValue: 1,
                                     duration: duration*opacityDurationMultiplier,
                                     timingFunction: CAMediaTimingFunctionName.easeOut,
                                     delegate: nil)
    
    animatedView.layer.add(opacityAnim, forKey: nil)
    animatedView.layer.opacity = 1
  }
  
  static func unmaskLayerCircled(unmask: Bool = true,
                                 layer animatedlayer: CALayer,
                                 location: CGPoint,
                                 duration: TimeInterval,
                                 animateOpacity: Bool = true,
                                 opacityDurationMultiplier: Double = 1,
                                 delegate: CAAnimationDelegate,
                                 completion: Closure? = nil) {
    
    let circlePathLayer = CAShapeLayer()
//    var _completionBlocks = completionBlocks
    var circleFrameTopCenter: CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
      return circleFrame
    }
    
    var circleFrameTop: CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    var circleFrameTopLeft: CGRect {
      return CGRect.zero
    }
    
    var circleFrameTouchPosition: CGRect {
      return CGRect(origin: location, size: .zero)
    }
    
    var circleFrameCenter: CGRect {
      var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
      let circlePathBounds = circlePathLayer.bounds
      circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
      circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
      return circleFrame
    }
    
    func circlePath(_ rect: CGRect) -> UIBezierPath {
      return UIBezierPath(ovalIn: rect)
    }
    
    circlePathLayer.frame = animatedlayer.bounds
    circlePathLayer.path = circlePath(circleFrameTouchPosition).cgPath
    animatedlayer.mask = circlePathLayer
    
    //        let center = lastPoint//(x: animatedView.bounds.midX, y: animatedView.bounds.midY)
    
    let finalRadius = max(abs(animatedlayer.bounds.width - location.x),
                          abs(animatedlayer.bounds.width - (animatedlayer.bounds.width - location.x)))//sqrt((center.x*center.x) + (center.y*center.y))
    
    let radiusInset = finalRadius * 1.5
    
    let outerRect = circleFrameTouchPosition.insetBy(dx: -radiusInset, dy: -radiusInset)
    
    let toPath = UIBezierPath(ovalIn: outerRect).cgPath
    
    let fromPath = circlePathLayer.path
    
    let anim = Animations.get(property: .Path,
                              fromValue: unmask ? fromPath as Any : toPath as Any,
                              toValue: unmask ? toPath : fromPath as Any,
                              duration: duration,
                              delay: 0,
                              repeatCount: 0,
                              autoreverses: false,
                              timingFunction: unmask ? .easeOut : .easeIn,
                              delegate: delegate,
                              isRemovedOnCompletion: true,
                              completionBlocks: [])
    anim.setValue(completion, forKey: "completion")
    circlePathLayer.add(anim, forKey: "path")
    circlePathLayer.path = unmask ? toPath : fromPath
   
    guard animateOpacity else { return }

    animatedlayer.opacity = 1//unmask ? 1 : 0//0
    let opacityAnim = Animations.get(property: .Opacity,
                                     fromValue: unmask ? 0 : 1,
                                     toValue: unmask ? 1 : 0,
                                     duration: unmask ? duration*opacityDurationMultiplier : duration/opacityDurationMultiplier,
                                     timingFunction: unmask ? .easeOut : .easeIn,
                                     delegate: nil)
    
    animatedlayer.add(opacityAnim, forKey: nil)
    animatedlayer.opacity = 1//unmask ? 1 : 0
  }
  
  static func reveal(present: Bool,
                     location: CGPoint = .zero,
                     view revealView: UIView,
                     fadeView: UIView,
                     color: UIColor,
                     duration: TimeInterval,
                     delegate: CAAnimationDelegate,
                     completion: Closure? = nil,
                     animateOpacity: Bool = true) {
    
           let circlePathLayer = CAShapeLayer()
           
           var circleFrameTouchPosition: CGRect {
             return CGRect(origin: location, size: .zero)
           }
           
           var circleFrameTopLeft: CGRect {
             return CGRect.zero
           }
           
           func circlePath(_ rect: CGRect) -> UIBezierPath {
             return UIBezierPath(ovalIn: rect)
           }
           
           circlePathLayer.frame = revealView.bounds
           circlePathLayer.path = circlePath(location == .zero ? circleFrameTopLeft : circleFrameTouchPosition).cgPath
           revealView.layer.mask = circlePathLayer
           
           let radiusInset =  sqrt(revealView.bounds.height*revealView.bounds.height + revealView.bounds.width*revealView.bounds.width + location.x*location.x + location.y*location.y)
           
           let outerRect = circleFrameTouchPosition.insetBy(dx: -radiusInset, dy: -radiusInset)
           
           let toPath = UIBezierPath(ovalIn: outerRect).cgPath
           
           let fromPath = circlePathLayer.path
           
           let anim = Animations.get(property: .Path,
                                     fromValue: present ? fromPath as Any : toPath,
                                     toValue: !present ? fromPath as Any : toPath,
                                     duration: duration,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: present ? .easeInEaseOut : .easeOut,
                                     delegate: delegate,
                                     isRemovedOnCompletion: true,
                                     completionBlocks: [{
             revealView.layer.mask = nil
             if !present {
               //                circlePathLayer.path = CGPath(rect: .zero, transform: nil)
               revealView.layer.opacity = 0
               //////                animatedView.alpha = 0
               ////                            animatedView.layer.mask = nil
             }
             completion?()
           }])
    
           circlePathLayer.add(anim, forKey: "path")
           circlePathLayer.path = !present ? fromPath : toPath
           
           let colorLayer = CALayer()
           if let collectionView = fadeView as? UICollectionView {
             colorLayer.frame = CGRect(origin: .zero, size: CGSize(width: collectionView.bounds.width, height: 3000))
           } else {
             colorLayer.frame = fadeView.layer.bounds
           }
           colorLayer.backgroundColor = color.cgColor//traitCollection.userInterfaceStyle == .dark ? UIColor.black.cgColor : UIColor.systemGray.cgColor
           colorLayer.opacity = present ? 0 : 1
           
           fadeView.layer.addSublayer(colorLayer)
           
           let opacityAnim = Animations.get(property: .Opacity,
                                            fromValue: present ? 0 : 1,
                                            toValue: present ? 1 : 0,
                                            duration: duration/2,
                                            timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                            delegate: delegate, completionBlocks: [{
             colorLayer.removeFromSuperlayer()
           }])
           colorLayer.add(opacityAnim, forKey: nil)
           colorLayer.opacity = !present ? 0 : 1
         }
}

func animateImageChange(imageView: UIImageView, fromImage: UIImage, toImage: UIImage, duration: CFTimeInterval) {
  
  let anim = CABasicAnimation(keyPath: "contents")
  anim.fromValue = fromImage
  anim.toValue = toImage
  anim.duration = duration
  imageView.layer.add(anim, forKey: nil)
  imageView.image = toImage
  imageView.contentMode = .scaleAspectFill
  
}


func animateFadeInOut(fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
  
  let anim = CABasicAnimation(keyPath: "opacity")//анимируемое свойство
  anim.fromValue = fromValue//стартовое значение
  anim.toValue = toValue//конечное значение
  
  return anim
  
}

func animateImageChange(annotationView: MKAnnotationView, fromImage: UIImage, toImage: UIImage, duration: CFTimeInterval) {
  
  let anim = CABasicAnimation(keyPath: "contents")
  anim.fromValue = fromImage
  anim.toValue = toImage
  anim.duration = duration
  annotationView.layer.add(anim, forKey: nil)
  annotationView.image = toImage
  
}



class AnimatedVisualEffectView: UIVisualEffectView {
  
  //    fileprivate var _effect: UIVisualEffect
  var beginAnimator: UIViewPropertyAnimator!
  let endAnimator: UIViewPropertyAnimator
  
  init(duration: TimeInterval, curve _curve: UIView.AnimationCurve) {
    //        beginAnimator = UIViewPropertyAnimator(duration: duration, curve: _curve)
    endAnimator   = UIViewPropertyAnimator(duration: duration, curve: _curve)//, effect _effect: UIVisualEffect)
    //        _effect = _effect
    
    super.init(effect: UIBlurEffect(style: .light))
    effect = UIBlurEffect(style: .light)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  //
  //    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
  //        // Get the hit view we would normally get with a standard UIView
  //        let hitView = super.hitTest(point, with: event)
  //
  //        // If the hit view was ourself (meaning no subview was touched),
  //        // return nil instead. Otherwise, return hitView, which must be a subview.
  //        return hitView == self ? nil : hitView
  //    }
  
  
}
