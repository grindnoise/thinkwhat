//
//  Card.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

protocol Card: UIView {
  var subscriptions: Set<AnyCancellable> { get set }
}
