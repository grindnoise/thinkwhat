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

func animateTransformScale(fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval, repeatCount: Float, autoreverses: Bool, timingFunction: String = CAMediaTimingFunctionName.default.rawValue as String) -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath:"transform.scale")
    anim.fromValue = fromValue
    anim.toValue = toValue
    anim.duration = duration
    anim.repeatCount = repeatCount
    anim.autoreverses = autoreverses
    anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: timingFunction))
    
    return anim
    
}

func animateTransformScale(fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
    
    let anim = CABasicAnimation(keyPath:"transform.scale")
    anim.fromValue = fromValue
    anim.toValue = toValue
    return anim
    
}


