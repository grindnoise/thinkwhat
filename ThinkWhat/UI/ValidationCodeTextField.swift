//
//  ValidationCodeTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.08.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ValidationCodeTextField: UITextField {
    
    var seconds: Int    = 600 {
        didSet {
            if seconds == 0 {
                emailResponse = nil
            }
        }
    }
    var timer           = Timer()
    var isTimerRunning  = false
    
    private var signSize = CGSize(width: 90, height: 32) {
        didSet {
            layoutSubviews()
        }
    }
    
    private var timerLabel:      UILabel!
    private var rightViewSize: CGSize {
        return CGSize(
            width: signSize.width,
            height: signSize.height)
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup() {
        borderStyle = .none
        rightViewMode = .always
        rightView = UIView()
        timerLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
        //        timerLabel.text = "08:59:59"
        timerLabel.font = UIFont(name: "OpenSans-Light", size: 15)
        timerLabel.textColor = .lightGray
        timerLabel.textAlignment = .right
        timerLabel.addEquallyTo(to: rightView!)
        NotificationCenter.default.addObserver(self, selector: #selector(ValidationCodeTextField.runTimer), name: kNotificationEmailResponseReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ValidationCodeTextField.destroyEmailResponse), name: kNotificationEmailResponseExpired, object: nil)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        rightView?.frame = rightViewRect(forBounds: frame)
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: bounds.width - rightViewSize.width, y: bounds.size.height / 2 - height / 2, width: width, height: height)
        
        return rect
    }
    
    open override func draw(_ rect: CGRect) {
        let width = CGFloat(4)
        let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = width
        tintColor.setStroke()
        
        path.stroke()
    }
    
    @objc private func runTimer() {
        if emailResponse != nil {
            seconds = Int(Date().timeIntervalSince(emailResponse!.expiresIn))
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ValidationCodeTextField.updateTimer)), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateTimer() {
        seconds -= 1
        timerLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    fileprivate func timeString(time:TimeInterval) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i"/*:%02i", hours*/, minutes, seconds)
    }
    
    @objc fileprivate func destroyEmailResponse() {
        emailResponse = nil
    }
}

