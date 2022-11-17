//
//  UIBarButton.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.11.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    var frame: CGRect? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view.frame
    }

}
