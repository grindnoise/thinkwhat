////
////  CustomNavigationController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 26.01.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class CustomNavigationController: UINavigationController {
//    
//    deinit {
//        print("CustomNavigationController deinit")
//        viewControllers.removeAll()
//    }
//    
//    enum TransitionStyle {
//        case Default, Auth
//        
//        func transition(navigationController _nav: UINavigationController, operation: UINavigationController.Operation) -> UIViewControllerAnimatedTransitioning? {
//            switch self {
//            case .Auth:
//                guard let nav = _nav as? CustomNavigationController else { return nil }
//                return AuthTransition(navigationController: nav, operation: operation)
//            default:
//                return nil
//            }
//        }
//    }
//    
//    var duration: TimeInterval = 0
//    var isShadowed = false {
//        didSet {
//            if oldValue != isShadowed {
//                navigationBar.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
//                let anim = Animations.get(property: .ShadowOpacity,
//                                          fromValue: isShadowed ? 0 : 1,
//                                          toValue: isShadowed ? 1 : 0,
//                                          duration: 0.2,
//                                          delay: 0,
//                                          timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                                          delegate: nil,
//                                          isRemovedOnCompletion: true,
//                                          completionBlocks: nil)
//                navigationBar.layer.shadowPath = UIBezierPath(rect: CGRect(origin: CGPoint(x: 0,
//                                                                                           y: navigationBar.bounds.height - navigationBar.bounds.height/3),
//                                                                           size: CGSize(width: navigationBar.bounds.width,
//                                                                                        height: navigationBar.bounds.height/3))).cgPath
//                navigationBar.layer.shadowRadius = 5
//                navigationBar.layer.shadowOffset = .zero
//                navigationBar.layer.zPosition = 100
//                CATransaction.begin()
//                navigationBar.layer.add(anim, forKey: "shadowOpacity")
//                CATransaction.commit()
//                navigationBar.layer.shadowOpacity = isShadowed ? 1 : 0
//            }
//        }
//    }
//    var category: Topic!
//    var transitionStyle: TransitionStyle = .Default
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        delegate = appDelegate.transitionCoordinator
//        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: StringAttributes.Fonts.Style.Bold, size: 20)!
//        ]
//        navigationBar.tintColor = .label
//    }
//    
//    override func present(_ viewControllerToPresent: UIViewController,
//                            animated flag: Bool,
//                            completion: (() -> Void)? = nil) {
//        viewControllerToPresent.modalPresentationStyle = .fullScreen
//        super.present(viewControllerToPresent,
//                      animated: flag,
//                      completion: completion)
//      }
//}
