//
//  NewPollImage.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class NewPollImage {
//  var order: Int
  let placeholder: String
  var text: String
  var image: UIImage
  
  init(image: UIImage,
       text: String) {
    self.image = image
    self.placeholder = text
    self.text = text
  }
}

extension NewPollImage: Hashable {
  static func == (lhs: NewPollImage, rhs: NewPollImage) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(text)
    hasher.combine(image)
  }
}

