//
//  RoundedImageView.swift
//  CityQuestProject
//
//  Created by Павел on 27.10.16.
//  Copyright © 2016 Павел. All rights reserved.
//

import UIKit

@IBDesignable class BorderedView: UIView {
    
    open var closure: Closure? = nil
    private var _rounded = false
    private var _bordered = false
    private var _borderColor = UIColor.clear
    private var _borderWidth: CGFloat = 0.0
//    private var _shadowed = false
    
    @IBInspectable var rounded: Bool {
        set {
            _rounded = newValue
            makeRounded()
        }
        get {
            return self._rounded
        }
    }
    
    @IBInspectable var bordered: Bool {
        set {
            _bordered = newValue
            makeBorder()
        }
        get {
            return self._bordered
        }
    }
    
    
    @IBInspectable var borderColor: UIColor {
        set {
            _borderColor = newValue
            //makeBorder()
        }
        get {
            return self._borderColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            _borderWidth = newValue
            makeBorder()
        }
        get {
            return self._borderWidth
        }
    }
    
//    @IBInspectable var shadowed: Bool {
//        set {
//            _shadowed = newValue
//            makeShadow()
//        }
//        get {
//            return self._shadowed
//        }
//    }
    
    override internal var frame: CGRect {
        set {
            super.frame = newValue
            makeRounded()
        }
        get {
            return super.frame
        }
    }
    
    private func makeRounded() {
        if self.rounded == true {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = 15
        } else {
            self.layer.cornerRadius = 0
        }
    }
    
    private func makeBorder() {
        if self.bordered == true {
            self.clipsToBounds = true
            self.layer.borderWidth = self._borderWidth
            self.layer.borderColor = self.borderColor.cgColor
        } else {
            self.layer.borderWidth = 0.0
        }
    }
//
//
//    private func makeShadow() {
//        if self.shadowed == true {
//            let shadowLayer = CALayer()
//            shadowLayer.masksToBounds = false
//            shadowLayer.shadowColor = UIColor.darkGray.cgColor
//            shadowLayer.shadowOffset = CGSize(width: 5.0, height: 5.0)
//            shadowLayer.shadowOpacity = 0.5
//            shadowLayer.shadowRadius = 10.0
//            self.layer.addSublayer(shadowLayer)
//        }
//    }
    
    override func layoutSubviews() {
        
        
        makeBorder()
        //makeShadow()
        makeRounded()

    }
}
