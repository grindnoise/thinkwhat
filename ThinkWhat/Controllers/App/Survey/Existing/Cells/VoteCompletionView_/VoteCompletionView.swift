//
//  VoteCompletionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoteCompletionView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var frameView: BorderedView!
    @IBOutlet      var lightBlurView: UIVisualEffectView!
    @IBOutlet weak var voteAnimation: VoteAnimationView!
    fileprivate var delegate: SurveyViewController?
    
    init(frame: CGRect, delegate: SurveyViewController?) {
        super.init(frame: frame)
        self.delegate = delegate
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("VoteCompletionView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        frameView.backgroundColor = .white
        frameView.borderWidth = 1.5
        frameView.borderColor = K_COLOR_GRAY
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
        voteAnimation.alpha = 0
        
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
        delay(seconds: 0.2) {
            UIView.animate(withDuration: 0.5, animations: {
                self.voteAnimation.alpha = 1
            }) {
                _ in
                self.voteAnimation.addEnableAnimation()
                delay(seconds: 2) {
                    self.dismiss()
                }
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
            self.voteAnimation.removeAllAnimations()
            self.removeFromSuperview()
        })
    }

}
