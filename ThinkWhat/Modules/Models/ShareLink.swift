//
//  SharedLink.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

struct ShareLink: Equatable {
  var hash: String
  var enc: String
  
  var isValid: Bool { !(hash.isEmpty && enc.isEmpty) }
  var urlEncoding: String { "\(hash)/\(enc)/" }
}
