//
//  Stack.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

public struct Stack<Element> {
  
  private let capacity: Int
  public private(set) var storage: [Element] = []
  public var isEmpty: Bool {
    peek() == nil
  }
  
  public init(capacity: Int) {
    self.capacity = capacity
  }
  
  public init(elements: [Element],
              capacity: Int) {
    self.capacity = capacity
    storage = elements
  }

  public func peek() -> Element? {
   storage.last
  }
  
  @discardableResult
  public mutating func push(_ element: Element) -> Element? {
    storage.insert(element, at: 0)
    
    guard storage.count > capacity else { return nil }

    return pop()
  }

  @discardableResult
  public mutating func pop() -> Element? {
    storage.popLast()
  }
}

extension Stack: CustomDebugStringConvertible {

  public var debugDescription: String {
    """
    ----top----
    \(storage.map { "\($0)" }.reversed().joined(separator: "\n"))
    -----------
    """
  }
}

//extension Stack: ExpressibleByArrayLiteral {
//  public init(arrayLiteral elements: Element...,
//              capacity: Int) {
//    self.capacity = capacity
//    storage = elements
//  }
//}
