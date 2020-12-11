//
//  Animations.swift
//  MapRiddle
//
//  Created by Pavel Bukharov on 12.07.17.
//  Copyright © 2017 Pavel Bukharov. All rights reserved.
//

import UIKit
import MapKit

func animateImageChange(imageView: UIImageView, fromImage: UIImage, toImage: UIImage, duration: CFTimeInterval) {
    
    let anim = CABasicAnimation(keyPath: "contents")
    anim.fromValue = fromImage
    anim.toValue = toImage
    anim.duration = duration
    imageView.layer.add(anim, forKey: nil)
    imageView.image = toImage
    imageView.contentMode = .scaleAspectFill
    
}

//MARK: - Animations
//Анимация вращения на 360
func animate360DegreesRotation(layer: CALayer, duration: CFTimeInterval = 1.0, keyValue: String? = nil) -> CABasicAnimation {
    
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

//Анимация прозрачности. Входные параметры: 1) анимируемый слой, 2) длительность (сек), 3) время задержки старта (по умолч в сек), 4) темп анимации (по умолч линейный). Возвращаемое значение - ссылка на созданную анимацию
func animateFadeInOut(layer: CALayer, fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval, beginTime: CFTimeInterval = 0.0, timingFunction:CAMediaTimingFunction, keyValue: String = "") -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath: "opacity")//анимируемое свойство
    anim.fromValue = fromValue//стартовое значение
    anim.toValue = toValue//конечное значение
    anim.duration = duration//длительность
    anim.beginTime = CACurrentMediaTime() + beginTime//время начала (берем текущее время и прибавляем задержку, если необходимо)
    anim.timingFunction = timingFunction//темп анимации (быстрое начало и медленное завершение, медленное начало и быстрое завершение и тд)
    anim.setValue(keyValue, forKey: "name")//добавляем характеристики
    anim.setValue(layer, forKey: "layer")
    //anim.delegate = self//делегат для выполнения протокола
    return anim
    
}

func animateFadeInOut(fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath: "opacity")//анимируемое свойство
    anim.fromValue = fromValue//стартовое значение
    anim.toValue = toValue//конечное значение
    
    return anim
    
}

func makeGroupAnimation(animations: [CAAnimation], duration: CFTimeInterval, timingFunction:CAMediaTimingFunction, repeatCount: Float, delegate: CAAnimationDelegate) -> CAAnimationGroup {
    
    let anim = CAAnimationGroup()
    anim.animations = animations
    anim.duration = duration
    anim.timingFunction = timingFunction
    anim.repeatCount = repeatCount
    anim.delegate = delegate
    
    return anim
    
}

//Анимация смены изображения v.1
//    static func animateImageChange(imageView: UIImageView, fromImage: UIImage, toImage: UIImage, duration: CFTimeInterval) {
//
//        let anim = CABasicAnimation(keyPath: "contents")
//        anim.fromValue = fromImage
//        anim.toValue = toImage
//        anim.duration = duration
//        imageView.layer.add(anim, forKey: nil)
//        imageView.image = toImage
//
//    }

//Анимация смены изображения v.2
func animateImageChange(annotationView: MKAnnotationView, fromImage: UIImage, toImage: UIImage, duration: CFTimeInterval) {
    
    let anim = CABasicAnimation(keyPath: "contents")
    anim.fromValue = fromImage
    anim.toValue = toImage
    anim.duration = duration
    annotationView.layer.add(anim, forKey: nil)
    annotationView.image = toImage
    
}

func animateTransformScale(fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval, repeatCount: Float, autoreverses: Bool, timingFunction: String = CAMediaTimingFunctionName.default.rawValue as String, delegate: CAAnimationDelegate?) -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath:"transform.scale")
    anim.fromValue = fromValue
    anim.toValue = toValue
    anim.duration = duration
    anim.repeatCount = repeatCount
    anim.autoreverses = autoreverses
    if delegate != nil {
        anim.delegate = delegate!
    }
    anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: timingFunction))
    
    return anim
    
}

func animateTransformScale(fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath:"transform.scale")
    anim.fromValue = fromValue
    anim.toValue = toValue
    return anim
    
}


//class CustomIntensityVisualEffectView: UIVisualEffectView {
//
////    fileprivate let _duration: TimeInterval
////    fileprivate let _intensity: CGFloat
////    fileprivate let _effect: UIVisualEffect
//    let animator: UIViewPropertyAnimator
//    /// Create visual effect view with given effect and its intensity
//    ///
//    /// - Parameters:
//    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
//    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
//    var delegate: CallbackDelegate?
//
//    init(effect: UIVisualEffect, duration: TimeInterval, intensity: CGFloat) {
////        _effect = effect
////        _duration = duration
////        _intensity = intensity
//        animator = UIViewPropertyAnimator(duration: duration, curve: .linear)
//        super.init(effect: nil)
//
////        animator = UIViewPropertyAnimator(duration: duration, curve: .linear)// { [unowned self] in self.effect = effect }
////        animator.fractionComplete = intensity
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError()
//    }
//
//
//
//    // MARK: Private
////    private var animator: UIViewPropertyAnimator!
//
//}
//
//import UIKit

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
