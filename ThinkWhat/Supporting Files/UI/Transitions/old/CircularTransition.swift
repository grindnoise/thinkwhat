//import UIKit
//
////class CircularTransition: NSObject {
////
////    var circle = UIView()
////
////    var startingPoint = CGPoint.zero {
////        didSet {
////            circle.center = startingPoint
////        }
////    }
////
////    var circleColor = UIColor.white
////
////    var duration = 0.35
////
////    enum CircularTransitionMode:Int {
////        case present, dismiss, pop
////    }
////
////    var transitionMode:CircularTransitionMode = .present
////
////}
////
////extension CircularTransition:UIViewControllerAnimatedTransitioning {
////    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
////        return duration
////    }
////
////    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
////        let containerView = transitionContext.containerView
////
////        if transitionMode == .present {
////            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
////                let viewCenter = presentedView.center
////                let viewSize = presentedView.frame.size
////
////                circle = UIView()
////
////                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
////                print(circle.frame)
////                circle.layer.cornerRadius = circle.frame.size.height / 2
////                circle.center = startingPoint
////                //UIApplication.shared.windows[0]
////                circle.backgroundColor = circleColor
////                circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
//////                circle.layer.zPosition = 10
////                containerView.addSubview(circle)
////
////
////                presentedView.setNeedsDisplay()
////                presentedView.center = viewCenter
////                presentedView.alpha = 0
////                containerView.addSubview(presentedView)
////
////                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
////                    self.circle.transform = CGAffineTransform.identity
////                    self.circle.backgroundColor = .white
////                    UIView.animate(withDuration: 0.2, delay: 0.15, options: [.curveEaseIn], animations: {
//////                        presentedView.transform = CGAffineTransform.identity
////                        presentedView.alpha = 1
////                        presentedView.setNeedsUpdateConstraints()
////                        }, completion: nil)
////                }, completion: { (success) in
////                    transitionContext.completeTransition(success)
////                })
////
////            }
////
////        }else{
////            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
////
////            if let returningView = transitionContext.view(forKey: transitionModeKey) {
////                let viewCenter = returningView.center
////                let viewSize = returningView.frame.size
////
////
////                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
////                print(circle.frame)
////                circle.layer.cornerRadius = circle.frame.size.height / 2
////                circle.center = startingPoint
////
////                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
////                    UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseOut], animations: {
////                        returningView.alpha = 0
////                    }, completion: nil)
////                    self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
////                    self.circle.backgroundColor = self.circleColor
//////                    returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
//////                    returningView.center = self.startingPoint
////
////                    if self.transitionMode == .pop {
////                        containerView.insertSubview(returningView, belowSubview: returningView)
////                        containerView.insertSubview(self.circle, belowSubview: returningView)
////                    }
////
////
////                }, completion: { (success:Bool) in
////                    returningView.center = viewCenter
////                    returningView.removeFromSuperview()
////
////                    self.circle.removeFromSuperview()
////
////                    transitionContext.completeTransition(success)
////
////                })
////
////            }
////
////
////        }
////
////    }
////
////
////    func frameForCircle (withViewCenter viewCenter:CGPoint, size viewSize:CGSize, startPoint:CGPoint) -> CGRect {
////        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
////        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
////
////        let offestVector = sqrt(xLength * xLength + yLength * yLength) * 2
////        let size = CGSize(width: offestVector, height: offestVector)
////
////        return CGRect(origin: CGPoint.zero, size: size)
////
////    }
////
////}
//
////protocol CircleTransitionable {
//////    var triggerView: UIView { get }
//////    var mainView: UIView { get }
////}
//
//class CircularTransition: NSObject, UIViewControllerAnimatedTransitioning {
//    var startingPoint = CGPoint.zero {
//        didSet {
//            circle.center = startingPoint
//        }
//    }
//    var circle = UIView()
//    var operation: UINavigationController.Operation!
//    var navigationController: NavigationControllerPreloaded!
//    var circleColor = K_COLOR_RED//UIColor.white
//    var duration = 0.37
//    
//    init(_ _navigationController: NavigationControllerPreloaded, _ _operation: UINavigationController.Operation, _ _startingPoint: CGPoint) {
//        navigationController = _navigationController
//        operation = _operation
//        startingPoint = _startingPoint
////        navigationController.
//    }
//    
//    weak var context: UIViewControllerContextTransitioning?
//    
//    //make this zero for now and see if it matters when it comes time to make it interactive
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return duration//0.0
//    }
//    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        if operation == .push {
//            guard let fromVC = transitionContext.viewController(forKey: .from),
//                let toVC = transitionContext.viewController(forKey: .to),
//                let snapshot = fromVC.tabBarController!.view.snapshotView(afterScreenUpdates: false) else {
//                    transitionContext.completeTransition(false)
//                    return
//            }
//            
//            let containerView = transitionContext.containerView
////            containerView.frame = CGRect(origin: containerView.frame.origin, size: CGSize(width: containerView.frame.size.width, height: containerView.frame.size.height - 49))
//            context = transitionContext
//            
//            //Animate old view offscreen
////            navigationController?.setNavigationBarHidden(true, animated: false)
////            navigationController?.setNavigationBarHidden(true, animated: false)
////            navigationController?.tabBarController?.setTabBarVisible(visible: false, animated: false)
////            navigationController.setNavigationBarHidden(true, animated: false)
////            navigationController.tabBarController?.setTabBarVisible(visible: false, animated: false)
//            
////            toVC.view.setNeedsLayout()
////            toVC.view.layoutIfNeeded()
////            containerView.setNeedsLayout()
////            containerView.layoutIfNeeded()
//            containerView.addSubview(snapshot)
//            fromVC.view.removeFromSuperview()
//            
//            //Growing Circular Mask
//            //containerView.addSubview(toVC.view)
//            print(navigationController.tabBarController?.view.frame)
//            print(navigationController.view.frame)
//            print(containerView.frame)
//            //toVC.view.frame = containerView.frame
//            print(toVC.view.frame)
////            toVC.view.addEquallyTo(to: containerView)
////            toVC.view.frame = CGRect(origin: CGPoint(x: containerView.frame.origin.x, y: containerView.frame.origin.y + 200) , size: CGSize(width: containerView.frame.size.width, height: containerView.frame.size.height - 49))
////            toVC.view.frame = CGRect(origin: CGPoint(x: toVC.view.frame.origin.x, y: toVC.view.frame.origin.y + 49), size: toVC.view.frame.size)
////            print(toVC.view.frame)
//            containerView.addSubview(toVC.view)
//            
//            animate(operation: operation, toView: toVC.view)
//        } else {
//            guard let fromVC = transitionContext.viewController(forKey: .from),
//                let toVC = transitionContext.viewController(forKey: .to) else {//,
//                    transitionContext.completeTransition(false)
//                    return
//            }
//            let viewCenter = fromVC.view.center
//            let viewSize = fromVC.view.frame.size
//            
//            let containerView = transitionContext.containerView
//            circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
//            circle.layer.cornerRadius = circle.frame.size.height / 2
//            circle.center = startingPoint
//            navigationController?.setNavigationBarHidden(true, animated: false)
//            
//            //
//            let snapshot = fromVC.tabBarController!.view.snapshotView(afterScreenUpdates: false)
//            context = transitionContext
//            
//            //Animate old view offscreen
//            containerView.addSubview(toVC.view)
//            containerView.addSubview(snapshot!)
//            fromVC.view.removeFromSuperview()
//            
//            //Growing Circular Mask
//            animate(operation: operation, toView: snapshot!)
//            
//            //
//            
////            fromVC.view.alpha = 0
////            circle.backgroundColor = .white
////            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
////                UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseOut], animations: {
////                    fromVC.view.alpha = 0
////                }, completion: nil)
////                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
////                self.circle.backgroundColor = K_COLOR_RED
////                containerView.insertSubview(self.circle, belowSubview: fromVC.view)
////            }, completion: { (success:Bool) in
////                fromVC.view.center = viewCenter
////                self.circle.removeFromSuperview()
////                fromVC.view.removeFromSuperview()
////                containerView.addSubview(toVC.view)
////
////                self.navigationController.tabBarController?.setTabBarVisible(visible: true, animated: false)
////                self.navigationController.setNavigationBarHidden(false, animated: false)
////                transitionContext.completeTransition(success)
////
////            })
//        }
//    }
//    
//
//    
//    func frameForCircle (withViewCenter viewCenter:CGPoint, size viewSize:CGSize, startPoint:CGPoint) -> CGRect {
//        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
//        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
//        
//        let offestVector = sqrt(xLength * xLength + yLength * yLength) * 2
//        let size = CGSize(width: offestVector, height: offestVector)
//        
//        return CGRect(origin: CGPoint.zero, size: size)
//        
//    }
//    
//    func animate(operation: UINavigationController.Operation, toView: UIView) {
//        var durationMultiplier = 1
//        //Starting Path
//        let rect = CGRect(x: startingPoint.x,
//                          y: startingPoint.y,
//                          width: 0,
//                          height: 0)
//        var circleMaskPathInitial = UIBezierPath(ovalIn: rect)
//        
//        //Destination Path
//        let extremePoint = CGPoint(x: startingPoint.x,
//                                   y: startingPoint.y)// - fullHeight)
//        //        sqrt(max((extremePoint.x*extremePoint.x), (extremePoint.y*extremePoint.y)))
//        let radius = sqrt((extremePoint.x*extremePoint.x) +
//            (extremePoint.y*extremePoint.y))
//        if operation == .push {
//            durationMultiplier = Int(radius) / 200
//        }
//        let initialRect = toView.frame.insetBy(dx: -radius, dy: -radius)
//        let finalRect = CGRect(origin: initialRect.origin, size: CGSize(width: initialRect.width, height: initialRect.width))
//        
//        var circleMaskPathFinal = UIBezierPath(ovalIn: finalRect)
//        
//        //Actual mask layer
//        let maskLayer = CAShapeLayer()
//        let redLayer = CAShapeLayer()
//        maskLayer.path = operation == .push ? circleMaskPathFinal.cgPath : circleMaskPathInitial.cgPath
//        
//        redLayer.path = operation == .push ? circleMaskPathFinal.cgPath : UIBezierPath(rect: toView.frame).cgPath//circleMaskPathInitial.cgPath//maskLayer.path
//        toView.layer.mask = maskLayer
//        redLayer.fillColor = operation == .push ? UIColor.clear.cgColor : K_COLOR_RED.cgColor
//        toView.layer.addSublayer(redLayer)
//        
//        //Mask Animation
//        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
//        maskLayerAnimation.fromValue = operation == .push ? circleMaskPathInitial.cgPath : circleMaskPathFinal.cgPath
//        maskLayerAnimation.toValue = operation == .push ? circleMaskPathFinal.cgPath : circleMaskPathInitial.cgPath
//        maskLayerAnimation.delegate = self
//        maskLayerAnimation.duration = duration * Double(durationMultiplier)
////        maskLayerAnimation.isRemovedOnCompletion = true
//        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        if operation == .pop {
//            maskLayerAnimation.setValue(toView, forKey: "removeView")
//        }
//        maskLayer.add(maskLayerAnimation, forKey: "path")
//        
//        let maskColorLayerAnimation = CABasicAnimation(keyPath: "fillColor")
//        maskColorLayerAnimation.fromValue = operation == .push ? K_COLOR_RED.cgColor : UIColor.clear.cgColor
//        maskColorLayerAnimation.toValue = operation == .push ? UIColor.clear.cgColor : K_COLOR_RED.cgColor
//        maskColorLayerAnimation.duration = duration
////        maskLayerAnimation.isRemovedOnCompletion = true
//        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        redLayer.add(maskColorLayerAnimation, forKey: "fillColor")
//    }
//}
//
//extension CircularTransition: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if let view = anim.value(forKey: "removeView") as? UIView {
//            self.navigationController.setNavigationBarHidden(false, animated: false)
//            view.removeFromSuperview()
//        }
//        context?.completeTransition(true)
//    }
//}
//
//
