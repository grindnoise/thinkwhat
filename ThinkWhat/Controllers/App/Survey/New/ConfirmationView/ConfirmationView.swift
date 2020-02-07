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
    @IBOutlet weak var frameView: BorderedView!
    @IBOutlet      var lightBlurView: UIVisualEffectView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    @IBAction func createTapped(_ sender: Any) {
//        if text.text.isEmpty {
//            UIView.animate(withDuration: 0, animations: {self.endEditing(true)}, completion: {
//                _ in
//                showAlert(type: .Warning, buttons: [["Отмена": [.Cancel: {self.dismiss(save: false)}]], ["Ввести текст": [.Ok: {self.text.becomeFirstResponder()}]]], text: "Введите текст или нажмите Отмена")
//            })
//        } else {
//            dismiss(save: true)
//        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(save: false)
    }

    fileprivate var delegate: UIViewController?
    
    init(frame: CGRect, delegate: UIViewController?) {
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
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    public func present() {
        layer.zPosition = 100
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        window?.windowLevel = UIWindow.Level.statusBar + 1
        contentView.alpha = 1
        lightBlurView.alpha = 0
        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        frameView.layer.opacity = 1
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            //self.contentView.alpha = 1
            self.lightBlurView.alpha = 1
        }, completion: nil)
        
        let scaleAnim       = CASpringAnimation(keyPath: "transform.scale")//CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
//        groupAnim.delegate = self
        
        scaleAnim.fromValue = 0.7
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
    }
    
    public func dismiss(save: Bool) {
        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue   = 0.7
        scaleAnim.duration  = 0.6
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 1
        fadeAnim.toValue    = 0
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 0.3
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        frameView.layer.add(groupAnim, forKey: nil)
        frameView.layer.opacity = Float(0)
        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.lightBlurView.alpha = 0
        }, completion: {
            _ in
            self.removeFromSuperview()
            self.contentView.alpha = 0
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar - 1
        })
    }
    
    
    

}
