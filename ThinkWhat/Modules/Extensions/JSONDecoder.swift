//
//  JSONDecoder.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

extension JSONDecoder {
  class func withDateTimeDecodingStrategyFormatters() -> JSONDecoder {
    let instance = JSONDecoder()
    instance.dateDecodingStrategyFormatters = [
      DateFormatter.ddMMyyyy,
      DateFormatter.dateTimeFormatter,
      DateFormatter.dateFormatter
    ]
    return instance
  }
}
