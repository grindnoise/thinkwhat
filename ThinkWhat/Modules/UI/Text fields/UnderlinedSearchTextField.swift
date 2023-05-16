//
//  UnderlinedSearchTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class UnderlinedSearchTextField: SearchTextField {
    @IBInspectable public var activeLineColor: UIColor {
        get {
            if let strokeColor = activeLine.layer.strokeColor {
                return UIColor(cgColor: strokeColor)
            }
            return .clear
        } set {
            activeLine.layer.strokeColor = newValue.cgColor
        }
    }
    
    @IBInspectable public var activeLineWidth: CGFloat {
        get {
            return activeLine.layer.lineWidth
        } set {
            activeLine.layer.lineWidth = newValue
        }
    }
    
    @IBInspectable public var animationDuration: Double = 0.25
    
    public var activeLine = Line()
    
    @IBInspectable public var lineColor: UIColor {
        get {
            if let strokeColor = line.layer.strokeColor {
                return UIColor(cgColor: strokeColor)
            }
            
            return .clear
        } set {
            line.layer.strokeColor = newValue.cgColor
        }
    }
    
    @IBInspectable public var lineWidth: CGFloat {
        get {
            return line.layer.lineWidth
        } set {
            line.layer.lineWidth = newValue
        }
    }
    
    public var line = Line()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeSetup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        calculateLine(line)
        
        guard isEditing else {
            return
        }
        
        calculateLine(activeLine)
    }
    
    private func initializeSetup() {
        observe()
        configureBottomLine()
        configureActiveLine()
    }
    
    private func configureBottomLine() {
        line.layer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(line.layer)
    }
    
    private func configureActiveLine() {
        activeLine.layer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(activeLine.layer)
    }
    
    private func observe() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(textFieldDidBeginEditing),
                                       name: UITextField.textDidBeginEditingNotification,
                                       object: self)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(textFieldDidEndEditing),
                                       name: UITextField.textDidEndEditingNotification,
                                       object: self)
    }
    
    @objc internal override func textFieldDidEndEditing() {
        clearResults()
        tableView?.reloadData()
        placeholderLabel?.attributedText = nil
        
        let groupAnim = CAAnimationGroup()
        let strokeStartAnimation = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: 1, toValue: 0.5, duration: animationDuration + 0.1)
        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeStart), fromValue: 0, toValue: 0.5, duration: animationDuration + 0.1)
        groupAnim.animations = [strokeEndAnimation, strokeStartAnimation]
        activeLine.layer.add(groupAnim, forKey: "ActiveLineEndAnimation")
        activeLine.layer.strokeStart = 0.5
        activeLine.layer.strokeEnd   = 0.5
    }
    
    @objc internal override func textFieldDidBeginEditing() {
        calculateLine(activeLine)
        
//        let animation = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: 0.0, toValue: 1.0, duration: animationDuration)
        let groupAnim = CAAnimationGroup()
        let strokeStartAnimation = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: 0.5, toValue: 1, duration: animationDuration)
        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeStart), fromValue: 0.5, toValue: 0, duration: animationDuration)
        groupAnim.animations = [strokeEndAnimation, strokeStartAnimation]
        activeLine.layer.add(groupAnim, forKey: "ActiveLineStartAnimation")
        activeLine.layer.strokeStart = 0
        activeLine.layer.strokeEnd   = 1
    }
    
    internal func calculateLine(_ line: Line) {

        line.path = UIBezierPath()
        
        let yOffset = frame.height - line.layer.lineWidth / 2
        
        let startPoint = CGPoint(x: 0, y: yOffset)
        line.path.move(to: startPoint)
        
        let endPoint = CGPoint(x: frame.width, y: yOffset)
        line.path.addLine(to: endPoint)
        
        let interfaceDirection = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
        let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
        
        line.layer.path = path.cgPath
    }
}
