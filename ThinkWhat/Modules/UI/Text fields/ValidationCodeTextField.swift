//
//  ValidationCodeTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.08.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ValidationCodeTextField: UITextField {
    
    fileprivate var caution:  UILabel!
    fileprivate var seconds: Int    = 600
    fileprivate var timer           = Timer()
    fileprivate var isTimerRunning  = false
    fileprivate var signSize = CGSize(width: 90, height: 32) {
        didSet {
            layoutSubviews()
        }
    }
    
    fileprivate var timerLabel:      UILabel!
    fileprivate var rightViewSize: CGSize {
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
        NotificationCenter.default.addObserver(self, selector: #selector(ValidationCodeTextField.runTimer), name: Notifications.EmailResponse.Received, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ValidationCodeTextField.showCaution), name: Notifications.EmailResponse.Expired, object: nil)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        rightView?.frame = rightViewRect(forBounds: frame)
        if caution == nil {
            caution = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: frame.maxY), size: CGSize(width: frame.width, height: 16)))
            caution.alpha = 0
            caution.text = "Code has expired, send again"
            caution.textColor = .red
            superview?.addSubview(caution)
        }
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
        if !EmailResponse.shared.isEmpty && EmailResponse.shared.isActive {
            if EmailResponse.shared.getExpireDate() != nil {
                seconds = Int(Date().timeIntervalSince(EmailResponse.shared.getExpireDate()!))
            } else {
                seconds = 60
            }
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ValidationCodeTextField.updateTimer)), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateTimer() {
        seconds -= 1
        timerLabel.text = timeString(time: TimeInterval(seconds))
        if seconds == 0 {
            NotificationCenter.default.post(name: Notifications.EmailResponse.Expired, object: nil)
        }
    }
    
    fileprivate func timeString(time:TimeInterval) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i"/*:%02i", hours*/, minutes, seconds)
    }
    
    @objc fileprivate func showCaution() {
        UIView.animate(withDuration: 0.15) {
            self.caution.alpha = 1
        }
    }
}

