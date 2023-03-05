//
//  Queue.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

public protocol Queue {
  associatedtype Element
  mutating func enqueue(_ element: Element) -> Bool
  mutating func enqueue(_ elements: [Element]) -> Bool
  mutating func dequeue() -> Element?
  var isEmpty: Bool { get }
  var peek: Element? { get }
}
