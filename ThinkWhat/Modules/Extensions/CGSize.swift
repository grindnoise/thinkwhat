//
//  CGSize.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

extension CGSize {
  static func uniform(size: CGFloat) -> CGSize {
      return CGSize(width: size, height: size)
  }
}
