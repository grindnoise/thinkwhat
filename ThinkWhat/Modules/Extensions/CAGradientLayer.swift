//
//  CAGradientLayer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import QuartzCore

extension CAGradientLayer {
  func setGradient(colors: [CGColor],
                   locations: [NSNumber]) {
    self.colors = colors
    self.locations = locations
  }
}
