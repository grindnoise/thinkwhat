//
//  NavigationControler
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class NavigationControllerPreloaded: UINavigationController {
    
    enum TransitionStyle {
        case Icon, Default, Blur, Circular, Fade
    }
    var duration: TimeInterval = 0
    var isShadowed = false {
        didSet {
            if oldValue != isShadowed {
                navigationBar.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
                let shadowSize: CGFloat = 5
//                let contactRectTB = CGRect(x: -shadowSize, y: -shadowSize, width: tbView.frame.width + shadowSize * 2, height: shadowSize)
                let anim = Animations.get(property: .ShadowOpacity, fromValue: isShadowed ? 0 : 1, toValue: isShadowed ? 1 : 0, duration: 0.2, delay: 0, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: true, completionBlocks: nil)
                navigationBar.layer.shadowPath = UIBezierPath(rect: navigationBar.bounds).cgPath//contactRect).cgPath
                navigationBar.layer.shadowRadius = 5
                navigationBar.layer.shadowOffset = .zero
                navigationBar.layer.zPosition = 100
                CATransaction.begin()
                navigationBar.layer.add(anim, forKey: "shadowOpacity")
                CATransaction.commit()
                navigationBar.layer.shadowOpacity = isShadowed ? 1 : 0
            }
        }
    }
    var category: SurveyCategory!
    var transitionStyle: TransitionStyle = .Icon {
        didSet {
            print(transitionStyle)
        }
    }
//    var snapshotParent: UIView?
//    var snapshotChild:  UIView?
//    override var tabBarController: UITabBarController? {
//        return nil
//    }
//
    var startingPoint = CGPoint.zero {
        didSet {
            if startingPoint == .zero {
//                delegate = nil
            } else {
                delegate = appDelegate.transitionCoordinator
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NavigationControllerPreloaded \(self)")
        DispatchQueue.main.async {
            self.viewControllers.forEach { $0.view }
            
        }
        print("Testing")
        delegate = appDelegate.transitionCoordinator
    }
    
    
}
