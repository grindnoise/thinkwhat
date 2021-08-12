//
//  BannerContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 09.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol BannerContent {
    var foldable: Bool {get set}
    var minHeigth: CGFloat {get}
    var maxHeigth: CGFloat {get}
}
