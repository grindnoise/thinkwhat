//
//  CostItem.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import Combine

class CostItem: Hashable {
  
  let id = UUID()
  var title: String
  @Published var cost: Int
  var type: CostCollectionView.Section
  @Published var isNegative = false
  
  init(type: CostCollectionView.Section,
       title: String,
       cost: Int) {
    self.type = type
    self.title = title
    self.cost = cost
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(cost)
  }
  
  static func == (lhs: CostItem, rhs: CostItem) -> Bool {
    lhs.id == rhs.id
  }
}
