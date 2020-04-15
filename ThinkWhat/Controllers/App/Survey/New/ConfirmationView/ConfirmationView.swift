//
//  ConfirmationView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class ConfirmationView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var frameView: BorderedView!
    @IBOutlet      var lightBlurView: UIVisualEffectView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsHeight: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingIdicator: LoadingIndicator!
    @IBOutlet weak var readySign: ReadySign!
    fileprivate var defaultButtonsHeight: CGFloat = 0
    
    @IBAction func createTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.loadingIdicator.addEnableAnimation()
            self.loadingView.alpha = 1
            self.buttonsView.alpha = 0
            self.title.alpha = 0
        }
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut], animations: {
            self.setNeedsLayout()
            self.buttonsHeight.constant = self.title.frame.height
            self.layoutIfNeeded()
        })
        
        //POST request
        delegate?.postSurvey()
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss()
    }

    fileprivate var delegate: NewSurveyViewController?
    
    init(frame: CGRect, delegate: NewSurveyViewController?) {
        super.init(frame: frame)
        self.commonInit()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ConfirmationView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        frameView.backgroundColor = .white
        frameView.borderWidth = 1.5
        frameView.borderColor = K_COLOR_GRAY
        createButton.layer.cornerRadius = createButton.frame.height / 2
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    public func present() {
        layer.zPosition = 100
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        contentView.alpha = 1
        lightBlurView.alpha = 0
        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        frameView.layer.opacity = 1
        loadingView.alpha = 0
        if defaultButtonsHeight != 0 {
            defaultButtonsHeight = buttonsView.frame.height
            buttonsHeight.constant = defaultButtonsHeight
        }
        buttonsView.alpha = 1
        title.alpha = 1
        readySign.alpha = 0
        readySign.removeAllAnimations()
        
        delegate?.statusBarHidden = true
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.lightBlurView.alpha = 1
        }, completion: nil)
        
        //Slight scale/fade animation
        let scaleAnim       = CASpringAnimation(keyPath: "transform.scale")//CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        
        scaleAnim.fromValue = 0.7
        scaleAnim.toValue   = 1.0
        scaleAnim.duration  = 0.9
        scaleAnim.damping   = 14
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 0
        fadeAnim.toValue    = 1
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 1.3
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        frameView.layer.add(scaleAnim, forKey: nil)
        frameView.layer.opacity = Float(1)
        frameView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        delay(seconds: 1) {
            if self.defaultButtonsHeight != 0 {
                self.defaultButtonsHeight = self.buttonsView.frame.height
            }
        }
    }
    
    public func dismiss() {
        //Slight scale/fade animation
        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue   = 0.7
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 1
        fadeAnim.toValue    = 0
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 0.4
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        frameView.layer.add(groupAnim, forKey: nil)
        frameView.layer.opacity = Float(0)
        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        
        delegate?.statusBarHidden = false
        UIView.animate(withDuration: 0.4, delay: 1, options: [.curveEaseOut], animations: {
            self.lightBlurView.alpha = 0
            self.contentView.alpha = 0
        }, completion: {
            _ in
            self.loadingIdicator.removeAllAnimations()
            self.removeFromSuperview()
        })
    }
    
    deinit {
        print("ConfirmationView deinit")
    }
    
    func showReadySign() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingView.alpha = 0
        }) {
            _ in
            self.readySign.alpha = 1
            self.readySign.addUntitled1Animation()
            delay(seconds: 2.5) {
                self.delegate?.navigationController?.popViewController(animated: false)
                self.dismiss()
            }
        }
    }
}
