//
//  QueueArray.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

public struct QueueArray<T: Hashable>: Queue {
  private var array: [T] = []
  public init() {}
  
  public var isEmpty: Bool {
    array.isEmpty
  }
  
  public var peek: T? {
    array.first
  }
  
  public mutating func enqueue(_ element: T) -> Bool {
    guard array.filter({ $0 == element }).isEmpty else {
      return false
    }
    
    array.append(element)
    
    return true
  }
  
  @discardableResult
  public mutating func enqueue(_ elements: [T]) -> Bool {
    let existingSet = Set(array)
    let appendingSet = Set(elements)
    let difference = Array(existingSet.symmetricDifference(appendingSet))
    
    guard !difference.isEmpty else { return false }
    
    array.append(contentsOf: difference)
    
    return true
  }
  
  @discardableResult
  public mutating func dequeue() -> T? {
    isEmpty ? nil : array.removeFirst()
  }
}

extension QueueArray: CustomStringConvertible {
  public var description: String { String(describing: array) }
}
