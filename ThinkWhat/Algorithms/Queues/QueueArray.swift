//
//  QueueArray.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

public struct QueueArray<T: Hashable>: Queue {
  private var array: [T] = []
  public init() {}
  
  public var elements: [T] { array }
  
  public var length: Int { return array.count }
  
  public var isEmpty: Bool { array.isEmpty }
  
  public var peek: T? { array.first }
  
  public mutating func enqueue(_ element: T) -> Bool {
    guard array.filter({ $0 == element }).isEmpty else {
      return false
    }
    
    array.append(element)
    
    return true
  }
  
  @discardableResult
  public mutating func enqueue(_ elements: [T]) -> Bool {
    print(elements)
    guard !array.isEmpty else { array.append(contentsOf: elements); return true }
    
    let existingSet = Set(array)
    let appendingSet = Set(elements)
    let difference = Array(appendingSet.subtracting(existingSet))

    guard !difference.isEmpty else { return false }
    
    array.append(contentsOf: difference)
    
    return true
  }
  
  @discardableResult
  public mutating func dequeue() -> T? {
    isEmpty ? nil : array.removeFirst()
  }
  
  public mutating func remove(_ elements: [T]) {
    elements.forEach { print($0); array.remove(object: $0) }
  }
  
  public mutating func remove(_ element: T) {
    array.remove(object: element)
  }
}

extension QueueArray: CustomStringConvertible {
  public var description: String { String(describing: array) }
}
