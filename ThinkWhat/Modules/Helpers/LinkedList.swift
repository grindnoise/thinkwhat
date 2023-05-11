//
//  LinkedList.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

// Copyright (c) 2021 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public class Node<Value> {
  public var value: Value
  public var next: Node?
  
  public init(value: Value, next: Node? = nil) {
    self.value = value
    self.next = next
  }
}

extension Node: CustomStringConvertible {
  public var description: String {
    guard let next = next else {
      return "\(value)"
    }
    
    return "\(value) -> " + String(describing: next) + " "
  }
}


//example(of: "creating and linking nodes") {
//  let node1 = Node(value: 1)
//  let node2 = Node(value: 2)
//  let node3 = Node(value: 3)
//
//  node1.next = node2
//  node2.next = node3
//
//  print(node1)
//}

public struct LinkedList<Value> {
  public var head: Node<Value>?
  public var tail: Node<Value>?
  
  public init() {}
  
  public var isEmpty: Bool { head == nil }
  
//  public mutating func push(value: Value) {
//    guard let head = head else {
//      head = Node(value: value)
//
//      return
//    }
//
//    let newHead = Node(value: value, next: head.next)
//    newHead.next = head
//    self.head = newHead
//  }
  
  public mutating func push(value: Value) {
    copyNodes()
    head = Node(value: value, next: head)
    if tail == nil {
      tail = head
    }
  }
  
  public mutating func append(_ value: Value) {
    copyNodes()
    guard !isEmpty else {
      push(value: value)
      
      return
    }
    
    tail!.next = Node(value: value)
    tail = tail!.next
  }
  
  public func node(at index: Int) -> Node<Value>? {
    var currentIndex = 0
    var currentNode = head
    
    while let nextNode = currentNode?.next, index > currentIndex {
      currentIndex += 1
      currentNode = nextNode
    }
    
    return currentNode
  }
  
  @discardableResult
  public mutating func insert(_ value: Value, after node: Node<Value>) -> Node<Value> {
    copyNodes()
    guard tail !== head else {
      append(value)
      
      return tail!
    }
    
    node.next = Node(value: value, next: node.next)
    
    return node.next!
  }
  
  public mutating func pop() -> Value? {
    copyNodes()
    defer {
      head = head?.next
      
      if isEmpty {
        tail = nil
      }
    }
    
    return head?.value
  }
  
  public mutating func removeLast() -> Value? {
    copyNodes()
    guard let head = head else { return nil }
    
    guard head.next != nil else {
      return pop()
    }
    
    var current = head
    var previous = head
    
    while let nextNode = current.next {
      previous = current
      current = nextNode
    }
    
    previous.next = nil
    tail = previous
    return current.value
  }
  
  public mutating func remove(after node: Node<Value>) -> Value? {
//    copyNodes()
    guard let nodeCopy = copyNodes(returningCopyOf: node) else { return nil }
    
    defer {
      ///If this is the last node
      if nodeCopy.next === tail {
        tail = nodeCopy
      }
      ///Replace
      nodeCopy.next = nodeCopy.next?.next
    }
    
    return nodeCopy.next?.value
  }
  
  public mutating func reverse() {
    tail = head
    ///Предыдущий
    var prev = head
    var current = head?.next
    head?.next = nil
    while current != nil {
      let next = current?.next
      ///Ставим следющей нодой текущего элемента предыдущую ноду
      current?.next = prev
      prev = current
      ///Двигаем итератор
      current = next
    }
    
//    var tmpList = LinkedList<Value>()
//    for value in self {
//      tmpList.push(value: value)
//    }
//
//    head = tmpList.head
    head = prev
  }
  
  private func printInReverse<T>(_ node: Node<T>?) {
    guard let node = node else { return }
    
    printInReverse(node.next)
  }
  
  private mutating func copyNodes() {
    ///Unique pointer
    guard isKnownUniquelyReferenced(&head) else { return }
    
    guard var oldNode = head else {
      return
    }
    
    head = Node(value: oldNode.value)
    var newNode = head
    
    while let nextOldNode = oldNode.next {
      newNode!.next = Node(value: nextOldNode.value)
      newNode = newNode!.next
      
      oldNode = nextOldNode
    }
    
    tail = newNode
  }
  
  private mutating func copyNodes(returningCopyOf node: Node<Value>?) -> Node<Value>? {
    guard !isKnownUniquelyReferenced(&head) else { return nil }
    
    guard var oldNode = head else {
      return nil
    }

    head = Node(value: oldNode.value)
    var newNode = head
    var nodeCopy: Node<Value>?

    while let nextOldNode = oldNode.next {
      if oldNode === node {
        nodeCopy = newNode
      }
      newNode!.next = Node(value: nextOldNode.value)
      newNode = newNode!.next
      oldNode = nextOldNode
    }

    return nodeCopy
  }
}

extension LinkedList where Value: Equatable {
  mutating func removeAll(_ value: Value) {
    while let head = self.head, head.value == value {
      self.head = head.next
    }
    
    var prev = head
    var current = head?.next
    
    while let currentNode = current {
      guard currentNode.value != value else {
        prev?.next = currentNode.next
        current = prev?.next
        continue
      }
      
      prev = current
      current = current?.next
    }
    
  }
}

extension LinkedList: CustomStringConvertible {
  public var description: String {
    guard let head = head else {
      return "Empty list"
    }
    
    return String(describing: head)
  }
}

extension LinkedList: Collection {
  
  public struct Index: Comparable {
    
    public var node: Node<Value>?
    
    static public func ==(lhs: Index, rhs: Index) -> Bool {
      switch (lhs.node, rhs.node) {
      case let (left?, right?):
        return left.next === right.next
      case (nil, nil):
        return true
      default:
        return false
      }
    }
    
    static public func <(lhs: Index, rhs: Index) -> Bool {
      guard lhs != rhs else {
        return false
      }
      let nodes = sequence(first: lhs.node) { $0?.next }
      return nodes.contains { $0 === rhs.node }
    }
  }
  
  public var startIndex: Index {
    Index(node: head)
  }
  
  public var endIndex: Index {
    Index(node: tail?.next)
  }
  
  public func index(after i: Index) -> Index {
    Index(node: i.node?.next)
  }
  
  public subscript(position: Index) -> Value {
    position.node!.value
  }
}
//extension LinkedList: Collection {
//  ///Dictates how the index can be incremented. You simply give it an index of the immediate next node
//  public func index(after i: Index) -> Index {
//    Index(node: i.node?.next)
//  }
//
//  ///The subscript is used to map an Index to the value in the collection. Since you’ve created the custom index, you can easily achieve this in constant time by referring to the node’s value
//  public subscript(position: Index) -> Value {
//    position.node!.value
//  }
//
//  public var startIndex: Index {
//    Index(node: head)
//  }
//
//  public var endIndex: Index {
//    Index(node: tail?.next)
//  }
//
//
//  public struct Index: Comparable {
//    public var node: Node<Value>?
//
//    public static func < (lhs: LinkedList<Value>.Index, rhs: LinkedList<Value>.Index) -> Bool {
//      guard lhs != rhs else { return false }
//
//      let nodes = sequence(first: lhs.node) { $0?.next }
//
//      return nodes.contains { $0 === rhs.node }
//    }
//
//    public static func == (lhs: Index, rhs: Index) -> Bool {
//      lhs.node?.next === rhs.node?.next
//      //      switch (lhs.node, rhs.node) {
//      //      case let (left, right):
//      //        left?.next = right?.next
//      //      default:
//      //        return false
//      //      }
//    }
//  }
//}

//example(of: "pushing to list") {
//  var list = LinkedList<Int>()
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//}

//example(of: "append to list") {
//  var list = LinkedList<Int>()
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//
//  list.append(4)
//  list.append(5)
//
//  print(list)
//}

//example(of: "node at") {
//  var list = LinkedList<Int>()
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//  print(list.node(at: 1)?.value)
//}

//example(of: "insert") {
//  var list = LinkedList<Int>()
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//
//  for _ in 0...3 {
//    list.insert(0, after: list.node(at: 1)!)
//  }
//
//  print(list)
//}

//example(of: "pop") {
//  var list = LinkedList<Int>()
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//
//  list.pop()
//
//  print(list)
//}

//example(of: "removeLast") {
//  var list = LinkedList<Int>()
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//
//  let removedLast = list.removeLast()
//  print("removedLast", String(describing: removedLast))
//}

//example(of: "remove after node") {
//  var list = LinkedList<Int>()
//  list.push(value: 5)
//  list.push(value: 4)
//  list.push(value: 3)
//  list.push(value: 2)
//  list.push(value: 1)
//
//  print(list)
//
//  let middle = list.node(at: 2)!
//  print(String(describing: list.remove(after: middle)))
//  print(list)
//}

//example(of: "using collection") {
//  var list = LinkedList<Int>()
//  for i in 0...9 {
//    list.append(i)
//  }
//
//  print("List: \(list)")
//  print("First element: \(list[list.startIndex])")
//  print("Array containing first 3 elements: \(Array(list.prefix(3)))")
//  print("Array containing last 3 elements: \(Array(list.suffix(3)))")
//
//  let sum = list.reduce(0, +)
//  print("Sum of all values: \(sum)")
//}

//example(of: "array cow") {
//  let array1 = [1, 2]
//  var array2 = array1
//
//  print("array1: \(array1)")
//  print("array2: \(array2)")
//
//  print("---After adding 3 to array 2---")
//  array2.append(3)
//  print("array1: \(array1)")
//  print("array2: \(array2)")
//}

//example(of: "linked list cow") {
//  var list1 = LinkedList<Int>()
//  list1.append(1)
//  list1.append(2)
//  list1.append(3)
//  var list2 = list1
//  print("List1: \(list1)")
//  print("List2: \(list2)")
////
////  print("After appending 3 to list2")
////  list2.append(3)
////  print("List1: \(list1)")
////  print("List2: \(list2)")
////  print("List1 uniquely referenced: \(isKnownUniquelyReferenced(&list1.head))")
////  var list2 = list1
////  print("List1 uniquely referenced: \(isKnownUniquelyReferenced(&list1.head))")
//
//  print("Removing middle node on list2")
//  if let node = list2.node(at: 0) {
//    list2.remove(after: node)
//  }
//  print("List2: \(list2)")
//}

private func printInReverse<T>(_ node: Node<T>?) {
  guard let node = node else { return }
  
  printInReverse(node.next)
  print(node.value)
}

func printInReverse<T>(_ list: LinkedList<T>) {
  printInReverse(list.head)
}

func getMiddle<T>(list: LinkedList<T>) -> Node<T>? {
  
  var slow = list.head
  var fast = list.head
  
  while let nextFast = fast?.next {
    fast = nextFast.next
    slow = slow?.next
  }
  
  return slow
}

func reversed<T>(_ list: LinkedList<T>) {//}-> LinkedList<T> {
  var tempList = LinkedList<T>()
  var listCopy = list
  
  while let popped = listCopy.pop() {
    tempList.push(value: popped)
  }
  
  print(tempList.description)
  print(list.description)
}


func mergeSorted<Value: Comparable>(left: LinkedList<Value>, right: LinkedList<Value>) -> LinkedList<Value>? {
  
  guard !left.isEmpty else {
    return right
  }

  guard !right.isEmpty else {
    return left
  }

  var newHead: Node<Value>?
  var tail: Node<Value>?
  var currentLeft = left.head
  var currentRight = right.head
  
  if let leftNode = currentLeft, let rightNode = currentRight {
    if leftNode.value < rightNode.value {
      newHead = leftNode
      currentLeft = leftNode.next
    } else {
      newHead = rightNode
      currentRight = rightNode.next
    }
    tail = newHead///Why?
  }
  
  while let leftNode = currentLeft, let rightNode = currentRight {
    if leftNode.value < rightNode.value {
      tail?.next = leftNode
      currentLeft = leftNode.next
    } else {
      tail?.next = rightNode
      currentRight = rightNode.next
    }
    tail = tail?.next
  }
  
  if let leftNodes = currentLeft {
    tail?.next = leftNodes
  }

  if let rightNodes = currentRight {
    tail?.next = rightNodes
  }
  
  var list = LinkedList<Value>()
  list.head = newHead
  list.tail = {
    while let next = tail?.next {
      tail = next
    }
    return tail
  }()
  return list
}

