//
//  AnyOptional.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

/// Allows to match for optionals with generics that are defined as non-optional.
public protocol AnyOptional {
  /// Returns `true` if `nil`, otherwise `false`.
  var isNil: Bool { get }
}

extension Optional: AnyOptional {
  public var isNil: Bool { self == nil }
}
