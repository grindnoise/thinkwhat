////
////  VoteCompletionView.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 06.04.2020.
////  Copyright © 2020 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class VoteCompletionView: UIView {
//
//    @IBOutlet       var contentView:        UIView!
//    @IBOutlet weak  var frameView:          BorderedView!
//    @IBOutlet       var lightBlurView:      UIVisualEffectView!
//    @IBOutlet weak  var voteAnimation:      VoteAnimationView!
//    fileprivate     var delegate:           SurveyViewController?
//    fileprivate     var loadingIndicator:   LoadingIndicator!
//
//    init(frame: CGRect, delegate: SurveyViewController?) {
//        super.init(frame: frame)
//        self.delegate = delegate
//        self.commonInit()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.commonInit()
//    }
//
//    fileprivate func commonInit() {
//        Bundle.main.loadNibNamed("VoteCompletionView", owner: self, options: nil)
//        guard let content = contentView else {
//            return
//        }
//        frameView.backgroundColor = .white
//        frameView.borderWidth = 1.5
//        frameView.borderColor = K_COLOR_GRAY
//        voteAnimation.alpha = 0
//        content.frame = self.bounds
//        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        self.addSubview(content)
//    }
//
//    public func present() {
//        layer.zPosition = 100
//        let window = UIApplication.shared.keyWindow
//        window?.addSubview(self)
//        contentView.alpha = 1
//        lightBlurView.alpha = 0
//        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
//        frameView.layer.opacity = 1
//        loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: frameView.frame.width, height: frameView.frame.width)))
//        loadingIndicator.layoutCentered(in: frameView, multiplier: 0.8)
//        loadingIndicator.alpha = 0
//
//        delegate?.statusBarHidden = true
//        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//            self.lightBlurView.alpha = 1
//        }, completion: nil)
//
//        //Slight scale/fade animation
//        let scaleAnim       = CASpringAnimation(keyPath: "transform.scale")//CABasicAnimation(keyPath: "transform.scale")
//        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
//        let groupAnim       = CAAnimationGroup()
//
//        scaleAnim.fromValue = 0.7
//        scaleAnim.toValue   = 1.0
//        scaleAnim.duration  = 0.9
//        scaleAnim.damping   = 14
//        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        fadeAnim.fromValue  = 0
//        fadeAnim.toValue    = 1
//
//        groupAnim.animations        = [scaleAnim, fadeAnim]
//        groupAnim.duration          = 1
//        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//
//        frameView.layer.add(scaleAnim, forKey: nil)
//        frameView.layer.opacity = Float(1)
//        frameView.layer.transform = CATransform3DMakeScale(1, 1, 1)
////        delay(seconds: 0.1) {
////            UIView.animate(withDuration: 0.3, animations: {
////                self.voteAnimation.alpha = 1
////            }) {
////                _ in
////                self.voteAnimation.addEnableAnimation()
////                delay(seconds: 1) {
////                    self.dismiss()
////                }
////            }
////        }
//        delay(seconds: 0.1) {
//            UIView.animate(withDuration: 0.3) {
//                self.loadingIndicator.alpha = 1
//                self.loadingIndicator.addEnableAnimation()
//            }
//        }
//    }
//
//    public func animate(_ completion: @escaping(Bool)->()) {
//        UIView.animate(withDuration: 0.7, animations: {
//            self.loadingIndicator.alpha = 0
//        }) {
//            _ in
//            self.loadingIndicator.removeAllAnimations()
//            self.voteAnimation.addEnableAnimation()
//            UIView.animate(withDuration: 1.1, delay: 0, options: .curveEaseOut, animations: {
//                self.voteAnimation.alpha = 1
//            })
////            UIView.animate(withDuration: 0.8) {//}, animations: {
////                self.voteAnimation.alpha = 1
//////            }) {
//////                _ in
//////                self.voteAnimation.addEnableAnimation()
////            }
//            delay(seconds: 1.1) {
//                self.dismiss() {
//                    completed in
//                    completion(completed)
//                }
//            }
//        }
//    }
//
//    func dismiss(_ completion: @escaping(Bool)->()) {
//        //Slight scale/fade animation
//        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
//        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
//        let groupAnim       = CAAnimationGroup()
//
//        scaleAnim.fromValue = 1.0
//        scaleAnim.toValue   = 0.7
//        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        fadeAnim.fromValue  = 1
//        fadeAnim.toValue    = 0
//
//        groupAnim.animations        = [scaleAnim, fadeAnim]
//        groupAnim.duration          = 0.2
//        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//
//        frameView.layer.add(groupAnim, forKey: nil)
//        frameView.layer.opacity = Float(0)
//        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
//        delay(seconds: 0.2) {
//            self.delegate?.statusBarHidden = false
//            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
//                self.lightBlurView.alpha = 0
//                self.contentView.alpha = 0
//                //            delay(seconds: 0.2) {
//                //                self.delegate?.statusBarHidden = false
//                //            }
//            }, completion: {
//                _ in
//                self.voteAnimation.removeAllAnimations()
//                self.loadingIndicator.removeAllAnimations()
//                self.removeFromSuperview()
//                completion(true)
//            })
//        }
//    }
//}
