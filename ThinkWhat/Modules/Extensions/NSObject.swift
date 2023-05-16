//
//  NSObject.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

extension NSObject {
  func copyObject<T: NSObject>() throws -> T? {
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
      return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
//      return try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data)
    } catch {
      throw error
    }
  }
}
