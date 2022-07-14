//
//  UIPropertyListener.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol BoundsListener: AnyObject {
    func onBoundsChanged(_: CGRect)
}
