//
//  Segues.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.05.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                       completion: { finished in
                        //src.present(dst, animated: false, completion: nil)
        }
        )
    }
}

class SegueFromTop: UIStoryboardSegue {
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        src.navigationController?.view.backgroundColor = .clear
        src.tabBarController?.view.backgroundColor = .red
        
        let height = src.view.frame.height
        
        let backgroundView = UIView(frame: dst.view.frame)
        backgroundView.layer.position.y -= height
        backgroundView.frame.origin = src.view.frame.origin
        backgroundView.frame.origin.y = src.view.frame.origin.y - height
        backgroundView.frame.size = src.view.frame.size
        backgroundView.backgroundColor = .white
        backgroundView.alpha = 1
        src.navigationController!.view.addSubview(backgroundView)
        let foregroundView = UIView(frame: dst.view.frame)
        foregroundView.backgroundColor = K_COLOR_RED
        foregroundView.addEquallyTo(to: backgroundView)
        
        dst.view.layer.position.y -= height
        dst.view.frame.origin = src.view.frame.origin
        dst.view.frame.origin.y = src.view.frame.origin.y - height
        dst.view.frame.size = src.view.frame.size
        dst.view.alpha = 0
        src.navigationController!.view.addSubview(dst.view)
        
        delay(seconds: 0.1) {
            if let rbtn = src.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                rbtn.alpha = 0
            }
            src.navigationItem.titleView?.alpha = 0
        }
        UIView.animate(withDuration: 0.33,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        foregroundView.alpha = 0
        })
        UIView.animate(withDuration: 0.33,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        //                        foregroundView.alpha = 0
                        backgroundView.frame.origin = src.view.frame.origin
                        dst.view.alpha = 1
                        dst.view.frame.origin = src.view.frame.origin
        },
                       completion: { finished in
                        foregroundView.removeFromSuperview()
                        backgroundView.removeFromSuperview()
                        src.navigationController!.pushViewController(dst, animated: false)
        })
    }
}


