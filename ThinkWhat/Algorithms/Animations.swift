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
    enum AnimationProperty: String {
        case FillColor       = "fillColor"
        case ShadowPath      = "shadowPath"
        case ShadowOpacity   = "shadowOpacity"
        case Scale           = "transform.scale"
        case Path            = "path"
        case BackgroundColor = "backgroundColor"
        case StrokeStart     = "strokeStart"
        case StrokeColor     = "strokeColor"
        case LineWidth       = "lineWidth"
        case Opacity         = "opacity"
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
        return anim
        
    }
    
    static func get(property: AnimationProperty, fromValue: Any, toValue: Any, duration: CFTimeInterval, delay beginTime: CFTimeInterval = 0.0, repeatCount: Float = 0, autoreverses: Bool = false, timingFunction: CAMediaTimingFunctionName = CAMediaTimingFunctionName.default, delegate: CAAnimationDelegate?, isRemovedOnCompletion: Bool = true, completionBlocks: [Closure]? = nil) -> CAAnimation {
        
        let anim = CABasicAnimation(keyPath: property.rawValue)
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
    
    static func changeImageCrossDissolve(imageView: UIImageView, image: UIImage, duration: TimeInterval = 0.5) {
        Task {
            await MainActor.run {
                UIView.transition(with: imageView,
                                  duration: duration,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    imageView.image = image
                })
            }
        }
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
