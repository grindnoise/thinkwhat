


//
//  CustomAlertView.swift
//  MapRiddle
//
//  Created by Pavel Bukharov on 04.09.17.
//  Copyright © 2017 Pavel Bukharov. All rights reserved.
//

import UIKit

class CustomAlertView: UIView, CAAnimationDelegate {
    
    public var isActive = false {
        didSet {
            print("oldValue = \(oldValue), newValue = \(isActive)")
        }
    }
    public enum AlertType {
        case Loading, FieldsNotFilled, InternetConnection, Warning, WrongCredentials, Ok
    }
    
    public enum ButtonType {
        case Ok, Cancel
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var frameView: BorderedView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertBody: UILabel!
    @IBOutlet weak var alertText: UILabel!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet      var lightBlurView: UIVisualEffectView!
    
    
    fileprivate var caller: UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    init(frame: CGRect, type: AlertType, buttons: [String : [ButtonType : Closure?]], title: String, body: String, caller: UIViewController!) {
        super.init(frame: frame)
        self.commonInit()
        self.caller = caller
        setupView(false, type: type, buttons: buttons, title: title, body: body)
    }
    
    init(frame: CGRect, type: AlertType, buttons: [String : [ButtonType : Closure?]], text: String, caller: UIViewController!) {
        super.init(frame: frame)
        self.commonInit()
        self.caller = caller
        setupView(true, type: type, buttons: buttons, title: text, body: "")
    }
    
    @objc fileprivate func handleOkTap(gesture: UITapGestureRecognizer) {
        var color = K_COLOR_RED.cgColor
        let anim = CABasicAnimation(keyPath: "backgroundColor")
        anim.duration = 0.5
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        var border: UIView?
        
        if gesture.state == .ended {
            if let borderView = gesture.view as? BorderedView{
                border = borderView
                color = UIColor(white: 1, alpha: 0.5).cgColor
                anim.fromValue = K_COLOR_RED
                anim.toValue = UIColor.clear.cgColor

                delay(seconds: 0.05, completion: {
                    self.dismissAlert()
                    if let closure = borderView.closure {
                        delay(seconds: 0.2, completion: {
                            closure()
                        })
                    }
                })
            }
        } else if gesture.state == .changed {
            if let borderView = gesture.view {
                border = borderView
                anim.fromValue = UIColor.clear.cgColor
                anim.toValue = K_COLOR_RED
            }
        }
        if (border != nil) {
            border!.layer.add(anim, forKey: nil)
            border!.layer.backgroundColor = UIColor.lightGray.cgColor//K_COLOR_RED.cgColor
        }
    }
    
    public func presentAlert() {
        layer.zPosition = 100
        UIApplication.shared.keyWindow?.addSubview(self)
        //UIApplication.shared.keyWindow?.addSubview(self)
        contentView.alpha = 1
        lightBlurView.alpha = 0
        frameView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        frameView.layer.opacity = 1
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            //self.contentView.alpha = 1
            self.lightBlurView.alpha = 1
        }, completion: nil)
        
        let scaleAnim       = CASpringAnimation(keyPath: "transform.scale")//CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        groupAnim.delegate = self
        
        scaleAnim.fromValue = 0.5
        scaleAnim.toValue   = 1.0
        scaleAnim.duration  = 0.9
        scaleAnim.damping   = 11
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 0
        fadeAnim.toValue    = 1
        
        //groupAnim.beginTime        += CACurrentMediaTime() + 0.2
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 1.3
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        //frameView.layer.add(groupAnim, forKey: nil)
        frameView.layer.add(scaleAnim, forKey: nil)
        frameView.layer.opacity = Float(1)
        frameView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        alert.isActive = true
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("CustomAlertView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        frameView.backgroundColor = .white
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    public func dismissAlert() {
        
        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue   = 0.5
        scaleAnim.duration  = 0.6
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 1
        fadeAnim.toValue    = 0
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 0.3
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        frameView.layer.add(groupAnim, forKey: nil)
        frameView.layer.opacity = Float(0)
        frameView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            //self.contentView.alpha = 0
            self.lightBlurView.alpha = 0
        }, completion: {
            _ in
            self.removeFromSuperview()
            self.isActive = false
            self.loadingIndicator.removeAllAnimations()
            self.contentView.alpha = 0
        })
        
    }
    
    public func setupView(_ singleLabel: Bool, type:AlertType, buttons: [String : [ButtonType : Closure?]]?, title: String?, body: String?) {
        
        upperView.layer.opacity     = 0
        middleView.layer.opacity    = 0
        lowerView.layer.opacity     = 0
        alertBody.layer.opacity     = singleLabel == true ? 0 : 1
        alertTitle.layer.opacity    = singleLabel == true ? 0 : 1
        alertText.layer.opacity     = singleLabel == true ? 1 : 0
        
        loadingIndicator.alpha = 0
        loadingIndicator.removeAllAnimations()
        
        alertText.text  = ""
        alertTitle.text = ""
        alertBody.text  = ""
        
        
        func setupViews(_: AlertType) {
            frameView.borderWidth = 1.5
            var img = UIView()
            
            switch type {
            case .Ok:
                print("f")
                //img = okTickSign(frame: imageContainer.frame)
            case .Warning:
                img = CustomAlertCautionSign(frame: imageContainer.frame)
            case .WrongCredentials:
                img = CustomAlertStopSign(frame: imageContainer.frame)
            default:
                print("")
            }
            
            switch singleLabel {
            case true:
                alertText.text = title
            case false:
                alertTitle.text = title
                alertBody.text  = body
            }
            
            //            if let _title = title {
            //                alertText.text = _title
            //                if let _body = body {
            //                    alertText.text = ""
            //                    let attrStr = NSMutableAttributedString(string: (_title + "\n" + "\n" + _body))
            //                    attrStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 13) ?? "", range: NSMakeRange(_title.count + 2, _body.count))
            //                    alertText.attributedText = attrStr
            //                    //alertText.text = alertText.text! + "\n" + "\n" + _body
            //                }
            //            }
            
            
            img.isOpaque = false
            img.translatesAutoresizingMaskIntoConstraints = false
            imageContainer.addSubview(img)
            img.addEquallyTo(to: imageContainer)
            
            //Кнопки
            let stackView = UIStackView(frame: lowerView.frame)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            for button in buttons! {
                let borderView = BorderedView(frame: lowerView.frame)
                borderView.borderColor = K_COLOR_GRAY//K_COLOR_RED//.white
                borderView.bordered = true
                borderView.translatesAutoresizingMaskIntoConstraints = false
                borderView.rounded = false
                borderView.borderWidth = 1.5
                borderView.alpha = 1
                stackView.addArrangedSubview(borderView)
                let label = UILabel(frame: borderView.frame)
                label.text = button.key
                label.textColor = K_COLOR_GRAY//K_COLOR_RED//.white
                label.font = UIFont(name: "OpenSans", size: 17)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                borderView.addSubview(label)
                label.addEquallyTo(to: borderView)
                
                let buttonAlertType = button.value.first?.key
                let closure: Closure? = button.value.first?.value
                borderView.closure = closure
                
                switch buttonAlertType! {
                case .Ok:
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleOkTap(gesture:)))
                    gesture.numberOfTapsRequired = 1
                    borderView.addGestureRecognizer(gesture)
                    //case Cancel:
                    
                default:
                    continue
                }
            }
            stackView.spacing = -1
            stackView.distribution = .fillEqually
            
            //Установим привязки к нижней секции окна
            self.lowerView.addSubview(stackView)
            stackView.addEquallyTo(to: lowerView)
            
            if (isActive) {
                let kDuration = 0.3
                let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
                let fadeAnim        = CABasicAnimation(keyPath: "opacity")
                let groupAnim       = CAAnimationGroup()
                
                scaleAnim.fromValue = 1.0
                scaleAnim.toValue   = 0.3
                fadeAnim.fromValue  = 1
                fadeAnim.toValue    = 0
                
                groupAnim.animations        = [scaleAnim, fadeAnim]
                groupAnim.duration          = 0.4
                groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                
                loadingIndicator.layer.add(groupAnim, forKey: nil)
                loadingIndicator.layer.opacity = Float(0)
                loadingIndicator.layer.transform = CATransform3DMakeScale(0.3, 0.3, 0.3)
                
                let fadeAnim_2        = CABasicAnimation(keyPath: "opacity")
                fadeAnim_2.fromValue  = 0
                fadeAnim_2.toValue    = 1
                fadeAnim_2.duration   = kDuration
                fadeAnim_2.beginTime  = CACurrentMediaTime() + 0.3
                fadeAnim_2.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                fadeAnim_2.isRemovedOnCompletion = false
                upperView.layer.add(fadeAnim_2, forKey: nil)
                middleView.layer.add(fadeAnim_2, forKey: nil)
                lowerView.layer.add(fadeAnim_2, forKey: nil)
                
                delay(seconds: 0.3, completion: {
                    self.upperView.alpha     = 1
                    self.middleView.alpha    = 1
                    self.lowerView.alpha     = 1
                })
                
            } else {
                upperView.alpha     = 1
                middleView.alpha    = 1
                lowerView.alpha     = 1
            }
        }
        
        
        for v in lowerView.subviews {
            v.removeFromSuperview()
        }
        
        for v in self.imageContainer.subviews {
            v.removeFromSuperview()
        }
        
        switch type {
        case .Loading:
            loadingIndicator.layer.transform = CATransform3DMakeScale(1, 1, 1)
            loadingIndicator.alpha = 0
            loadingIndicator.addUntitled1Animation()
            delay(seconds: 0.3, completion: {
                UIView.animate(withDuration: 0.2, animations: {
                    self.loadingIndicator.alpha = 1
                })
            })
            
        case .WrongCredentials:
            setupViews(.WrongCredentials)
        case .Warning:
            setupViews(.Warning)
        case .Ok:
            setupViews(.Ok)
        default:
            print("");
        }
}
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        frameView.layer.opacity = Float(1)
//        frameView.layer.transform = CATransform3DMakeScale(1, 1, 1)
    }
    
}

