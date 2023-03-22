//
//  NewPollChoice.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class NewPollChoice {
//  var order: Int
  let placeholder: String
  var text: String
  
  init(text: String) {
    self.placeholder = text
    self.text = text
  }
}

extension NewPollChoice: Hashable {
  static func == (lhs: NewPollChoice, rhs: NewPollChoice) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
//    hasher.combine(order)
    hasher.combine(text)
  }
}
