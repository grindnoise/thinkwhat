//
//  UIViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var previousController: UIViewController? {
        let i = navigationController?.viewControllers.firstIndex(of: self)
        return navigationController?.viewControllers[i!-1]
    }
}
