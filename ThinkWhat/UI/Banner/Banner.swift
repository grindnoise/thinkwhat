//
//  CostDetailBanner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class Banner: UIView {
    enum ContentType: Int {
        case None, TotaLCost
    }
    
    static let shared = Banner()
    var contentType: ContentType = .None {
        didSet {
            if oldValue != contentType {
                container.subviews.forEach { $0.removeFromSuperview() }
                switch contentType {
                case .TotaLCost:
                    if let subview = TotalCost.init(width: body.frame.width) as? UIView {
                        setNeedsLayout()
                        containerHeightConstraint.constant = subview.frame.height
                        layoutIfNeeded()
//                        subview.setNeedsLayout()
//                        subview.layoutIfNeeded()
                        subview.addEquallyTo(to: container)
//                        container.addSubview(subview)
                    }
                default:
                    print("ContentType.None")
                }
            }
        }
    }
    var content: UIView?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            background.alpha = 0
        }
    }
    @IBOutlet weak var body: UIView!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var container: UIView!
    
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.constant = topMargin
        }
    }
    private let topMargin:  CGFloat = 8
    private var yOrigin:    CGFloat = 0
    private var height:     CGFloat = 0 {
        didSet {
            if oldValue != height {
                yOrigin = -(height+topMargin)
                heightConstraint.constant   = height
            }
        }
    }
    private var keyWindow:  UIWindow!
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not for XIB/NIB")
    }
    
    private init() {
        super.init(frame: UIScreen.main.bounds)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Banner", owner: self, options: nil)
        guard let content = contentView, let _keyWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow else {
            return
        }
        backgroundColor             = .clear
        bounds                      = UIScreen.main.bounds
        content.frame               = bounds
        content.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
        keyWindow = _keyWindow
        keyWindow.addSubview(self)
        addSubview(content)
        
        //Set default height
        setNeedsLayout()
        height                      = content.bounds.width/3
        topConstraint.constant      = -(topConstraint.constant + height)
        layoutIfNeeded()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(recognizer:)))
        body.addGestureRecognizer(gestureRecognizer)
    }
    
    func present() {
        self.alpha = 1
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4,
            options: [.curveEaseInOut],
            animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.topMargin
                self.layoutIfNeeded()
        })
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.background.alpha = 1
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            self.setNeedsLayout()
            self.topConstraint.constant = self.yOrigin
            self.layoutIfNeeded()
            self.background.alpha = 0
        })
    }
    
    @objc private func viewPanned(recognizer: UIPanGestureRecognizer) {
        let minConstant = -(height+topMargin)
        guard topConstraint.constant <= topMargin else {
            return
        }
        let yTranslation = recognizer.translation(in: contentView).y
        topConstraint.constant += yTranslation
        
        if yTranslation > 0 {
            topConstraint.constant = min(topConstraint.constant, topMargin)
        }
        topConstraint.constant = topConstraint.constant < minConstant ? minConstant : topConstraint.constant
        
        recognizer.setTranslation(.zero, in: contentView)
        var yPoint = convert(body.frame.origin, to: contentView).y + height
        yPoint = yPoint < 0 ? 0 : yPoint
        background.alpha = yPoint/(height+topMargin)

        guard recognizer.state == .ended else {
            return
        }

        let yVelocity = recognizer.velocity(in: contentView).y
        let distance = abs(yOrigin) - abs(yPoint)
        if yVelocity < -500 {
            let time = TimeInterval(distance/abs(yVelocity)*2.5)
            let duration: TimeInterval = time < 0.08 ? 0.08 : time
            UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) {
                _ in
                self.alpha = 0
            }
        } else if background.alpha > 0.33 {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.topMargin
                self.layoutIfNeeded()
                self.background.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) {
                _ in
                self.alpha = 0
            }
        }
    }
}
