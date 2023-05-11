//
//  AppDelegate.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit
import CoreData
//import Swinject
import UserNotifications
//import FBSDKCoreKit
//import VK_ios_sdk
import SwiftyVK
import GoogleSignIn

//var vkDelegateReference : SwiftyVKDelegate?
let deviceType = UIDevice().type

public class ListNode {
     public var val: Int
     public var next: ListNode?
     public init() { self.val = 0; self.next = nil; }
     public init(_ val: Int) { self.val = val; self.next = nil; }
     public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let transitionCoordinator   = TransitionCoordinator()
  //    let container               = Container()
  let center                  = UNUserNotificationCenter.current()
  let notificationDelegate    = CustomNotificationDelegate()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //    printInReverse(["A", "B", "C", "D"])
    //    print("balanced", checkParenthesis("h((e))llo(world)()"))
    //    print("balanced", checkParenthesis("h((e))llo(world)("))
    
//        edu()
    API.shared.system.getCountryByIP()
    window = UIWindow()
    window?.rootViewController = UINavigationController(rootViewController: StartViewController())//AppData.accessToken.isNil || AppData.accessToken!.isEmpty ? UINavigationController(rootViewController: StartViewController()) : MainController()
    window?.makeKeyAndVisible()
    //        vkDelegateReference = VKDelegate()
    //        GIDSignIn.sharedInstance.restorePreviousSignIn()
    //        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    //        Settings.shared.isAdvertiserTrackingEnabled = false
    //        NetworkReachability.shared.startNetworkMonitoring()
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
#if DEBUG
    print(url)
#endif
    //    ///FB
    //    ApplicationDelegate.shared.application(
    //      app,
    //      open: url,
    //      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
    //      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    //    )
    ///VK
    let app = options[.sourceApplication] as? String
    VK.handle(url: url, sourceApplication: app)
    ///Google
    return GIDSignIn.sharedInstance.handle(url)
    //        return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  //    func applicationDidBecomeActive(_ application: UIApplication) {
  //        AppEvents.activateApp()
  //    }
  
  func applicationWillTerminate(_ application: UIApplication) {
    API.shared.cancelAllRequests()
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "ThinkWhat")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  //    func registerContainers() {
  ////        container.register(APIManagerProtocol.self) {
  ////            _ in APIManager()
  ////        }
  //        container.register(FileStorageProtocol.self) {
  //            _ in FileStorageManager()
  //        }
  //    }
  
  func edu() {
    //    var list1 = LinkedList<Int>()
    //    list1.append(1)
    //    list1.append(4)
    //    list1.append(10)
    //    list1.append(11)
    //
    //    var list2 = LinkedList<Int>()
    //    list2.append(-1)
    //    list2.append(0)
    //    list2.append(2)
    //    list2.append(9)
    //
    //    print(list1)
    //    mergeSorted(left: list1, right: list2)
    //    print(list1)
    //  }
    //
    //  @objc func checkInternetConnection() {
    //
    //    if Reachability.isConnectedToNetwork() {
    //      internetConnection = .Available
    //    } else {
    //      internetConnection = .None
    //    }
    //  }
    
    
//    let romans: [Character: Int] = [
//      "I": 1,
//      "V": 5,
//      "X": 10,
//      "L": 50,
//      "C": 100,
//      "D": 500,
//      "M": 1000,
//    ]
    
//    func romanToInt(_ string: String) -> Int {
//      guard string.count >= 1,
//            string.count <= 15,
//            Set(string.map { $0 }).subtracting(romans.keys).isEmpty
//      else { return 0 }
//
//      var digit = 0
//
//      var prev = string.reversed().first
//
//      string.reversed().enumerated().forEach { index, current in
//        guard index != 0 else { return }
//
//        if current == "I", (prev == "V" || prev == "X") {
//          digit += prev == "X" ? 9 : 4
//          prev = nil
//        } else if current == "X", (prev == "L" || prev == "C") {
//          digit += prev == "C" ? 90 : 40
//          prev = nil
//        } else if current == "C", (prev == "D" || prev == "M") {
//          digit += prev == "M" ? 900 : 400
//          prev = nil
//        } else {
//          if let prev = prev {
//            digit += romans[prev]!
//          }
//          if index == string.count - 1 {
//            digit += romans[current]!
//
//            prev = nil
//          } else {
//            prev = current
//          }
//        }
//      }
//
//      if let prev = prev {
//        digit += romans[prev]!
//      }
//
//      return digit
//    }
//
//    print(romanToInt("IX"))
//    print(romanToInt("VIII"))
//    print(romanToInt("LVIII"))
//    print(romanToInt("MCMXCIV"))
//    print(romanToInt("MMCDLI"))
//
//    print(romanToInt("D"))
    
    
//    func maximumWealth(_ accounts: [[Int]]) -> Int {
//      accounts.reduce(0, {
//        max($0, $1.reduce(0, +))
//      })
//
//      accounts.map { customer in
//        customer.reduce(into: 0) { $0 += $1 }
//      }.sorted { $0 > $1 }.max()
    //    }
    //
    //    print(maximumWealth([[1,5],[7,3],[3,5]]))
//    func numberOfSteps(_ num: Int) -> Int {
//      var out = num
//      var steps = 0
//
//      while out != 0 {
//        steps += 1
//        if out % 2 == 0 {
//          out /= 2
//        } else {
//          out -= 1
//        }
//      }
    //      return steps
    //    }
    
    
    
//      func middleNode(_ head: ListNode?) -> ListNode? {
//        guard head?.next != nil else { return head }
//
//        var fast = head
//        var slow = head
//
//        while let nextFast = fast?.next {
//          fast = nextFast.next
//          slow = slow?.next
//        }
//
//        return slow
//      }
//
//
//    let node0 = ListNode(1)
//    let node1 = ListNode(2)
//    let node2 = ListNode(3)
//    let node3 = ListNode(4)
//    let node4 = ListNode(5)
//    let node5 = ListNode(6)
//
//    node0.next = node1
//    node1.next = node2
//    node2.next = node3
//    node3.next = node4
//    node4.next = node5
//    print(middleNode(node0)?.val)
//    struct Row {
//      var index: Int
//      var count: Int
//    }
    
//    func kWeakestRows(_ mat: [[Int]], _ k: Int) -> [Int] {
//      var out = [Int: Int]()
////      var rows: [Row] = []
//      mat.enumerated().forEach { index, nested in
////        rows.append(Row(index: index,
////                        count: nested.filter { $0 == 0 }.count))
//        ///key is weak count
//        out[index] = nested.filter { $0 == 0 }.count
//      }
//      let test = Array(out.sorted (by: { lhs, rhs in
//        if lhs.value == rhs.value {
//          return lhs.key < rhs.key
//        }
//        return lhs.value > rhs.value
//      }).prefix(k)).map {
//        return $0.key
//      }
//
//      var arr = test.reduce(into: []) { $0.append($1)}
//
////      test.reduce([Int]) { $0.append($1) }
//
//      return [0]
//    }
//
//    var mat = [[1,1,0,0,0],
//               [1,1,1,1,0],
//               [1,0,0,0,0],
//               [1,1,0,0,0],
//               [1,1,1,1,1]]
//
    //    kWeakestRows(mat, 3)
    
//    enum OperationCase: Int, CaseIterable {
//      case Multiplication, Division, Addititon, Subtraction
//
//      func next() -> OperationCase {
//        switch self {
//        case .Multiplication:
//          return .Division
//        case .Division:
//          return .Addititon
//        case .Addititon:
//          return .Subtraction
//        case .Subtraction:
//          return .Multiplication
//        }
//      }
//    }
//
//    class Operation {
//      let value: Int
//      let type: OperationCase
//
//      init(value: Int, type: OperationCase) {
//        self.value = value
//        self.type = type
//      }
//    }
//
//    struct OperationQueue {
//      private var storage: [Operation] = []
//
//      public var isEmpty: Bool { storage.isEmpty }
//
//      public mutating func enqueue(_ operation: Operation) {
//        storage.append(operation)
//      }
//
//      public mutating func dequeue() -> Operation? {
//        guard !isEmpty else { return nil }
//
//        return storage.removeFirst()
//      }
//    }
//
//    func clumsy(_ n: Int) -> Int {
//      guard n > 1 else { return 1 }
//
//      var queue = OperationQueue()
//
//
//      func append(_ val: Int, _ operation: OperationCase) {
//        queue.enqueue(Operation(value: val, type: operation))
//      }
//
//      func multiply(_ left: Int, _ right: Int) -> Int {
//        left * right
//      }
//
//      func divide(_ left: Int, _ right: Int) -> Int {
//        Int(floor(Double(left) / Double(right)))
//      }
//
//      func add(_ left: Int, _ right: Int) -> Int {
//        left + right
//      }
//
//      func subtract(_ left: Int, _ right: Int) -> Int {
//        left - right
//      }
//
//      func group(_ count: inout Int, operation: Operation) {
//        count = operation.type == .Multiplication ? multiply(count, operation.value) : divide(count, operation.value)
//      }
//
//      var operation = OperationCase.Multiplication
//      append(n, .Multiplication)
//      (1...n-1).reversed().forEach{
//        append($0, operation)
//        operation = operation.next()
//      }
//
//      var currentOperation = queue.dequeue()!
//      var count = currentOperation.value
//      var joinedCount = 0
//      var isSubtracting = false {
//        didSet {
//          guard oldValue != isSubtracting,
//                !isSubtracting
//          else { return }
//
//          count = count - joinedCount
//          joinedCount = 0
//        }
//      }
//
//      while let nextOperation = queue.dequeue() {
//        switch nextOperation.type {
//        case .Multiplication:
//          if isSubtracting {
//            group(&joinedCount, operation: nextOperation)
//          } else {
//            count = multiply(count, nextOperation.value)
//          }
//        case .Division:
//          if isSubtracting {
//            group(&joinedCount, operation: nextOperation)
//          } else {
//            count = divide(count, nextOperation.value)
//          }
//        case .Addititon:
//          isSubtracting = false
//          count = add(count, nextOperation.value)
//        default:
//          isSubtracting = true
//          joinedCount = nextOperation.value
//  //        group(&joinedCount, operation: <#T##Operation#>)
//
//  //        count = subtract(count, futureMultiplication)
//
//        }
//        currentOperation = nextOperation
//      }
//
//      return count - joinedCount
//    }
//
//    print(clumsy(10))

//    func fizzBuzz(_ n: Int) -> [String] {
//      var out = [String]()
//
//      for i in 1...n {
//        if i % 3 == 0, i % 5 == 0 {
//          out.append("FizzBuzz")
//        } else if i % 3 == 0 {
//          out.append("Fizz")
//        } else if i % 5 == 0 {
//          out.append("Buzz")
//        } else {
//          out.append(String(describing: i))
//        }
//      }
//
//      return out
//    }
//
//    print(fizzBuzz(15))
    
    class ListNode {
      public var val: Int
      public var next: ListNode?
      public init() { self.val = 0; self.next = nil; }
      public init(_ val: Int) { self.val = val; self.next = nil; }
      public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
    }
    
//    func middleNode(_ head: ListNode?) -> ListNode? {
//        if head == nil {
//            return nil
//        }
//
//        var slow = head
//        var fast = head
//
//      while let nextFast = fast?.next {
//        fast = nextFast.next
//        slow = slow?.next
//      }
//
//        return slow
//    }
//
//    func reverseList(_ node: ListNode?) -> ListNode? {
//        var prev: ListNode? = nil
//        var current: ListNode? = node
//
//      while current != nil {
//        let next = current?.next
//        current?.next = prev//в первой итерации отключаем следующую ноду, в последующих head - предыдущее значение
//        prev = current//сдвигаем head вправо
//        current = next//итератор
//      }
//
//      return prev
//    }
//
//    func isPalindrome(_ head: ListNode?) -> Bool {
//            if head == nil {
//                return false
//            }
//
//            var straightNode: ListNode? = head
//
//            var middle = middleNode(head)
//            var reversed = reverseList(middle)
//
//            while reversed != nil {
//                if straightNode!.val != reversed!.val {
//                    return false
//                }
//
//                straightNode = straightNode?.next
//                reversed = reversed?.next
//            }
//
//            return true
//        }
//
//    func reversed(_ head: ListNode?) -> ListNode? {
//      var current = head
//      var prev: ListNode? = nil
//
//      while current != nil {
//        let next = current?.next//2->3->4->nil
//        current?.next = prev//nil->1->2->3
//        prev = current//1->2->3->4
//        current = next//2->3->4->nil
//      }
//
//      return prev
//    }
//
//    func middle(_ head: ListNode?) -> ListNode? {
//      var slow = head
//      var fast = head
//
//      while let nextFast = fast?.next {
//        slow = slow?.next
//        fast = nextFast.next
//      }
//
//      return slow
//    }
//
//    func checkPalindrome(_ _straight: ListNode?, _ _reversed: ListNode?) -> Bool {
//
//
//      var straight: ListNode? = _straight
//      var reversed: ListNode? = _reversed
//
//      while straight != nil, reversed != nil {
//        guard straight?.val == reversed?.val else { return false }
//
//        straight = straight?.next
//        reversed = reversed?.next
//      }
//
//      return true
//    }
//
////    let node0 = ListNode(1)
////    let node1 = ListNode(2)
////    let node2 = ListNode(3)
////    let node3 = ListNode(4)
////    let node4 = ListNode(5)
////    let node5 = ListNode(6)
////    let node6 = ListNode(7)
////    let node4 = ListNode(2)
////    let node5 = ListNode(1)
////    let node6 = ListNode(0)
////    }
////
//    let node0 = ListNode(1)
//    let node1 = ListNode(1)
//    let node2 = ListNode(1)
//    let node3 = ListNode(0)
//    let node4 = ListNode(1)
////    let node5 = ListNode(1)
////    let node6 = ListNode(0)
////    let node4 = ListNode(5)
////    let node5 = ListNode(6)
//
//    node0.next = node1
//    node1.next = node2
//    node2.next = node3
//    node3.next = node4
////    node4.next = node5
////    node5.next = node6
////    reverseList(node0)
////    reversed(node0)
//    let middle = middle(node0)
//    let reversed = reversed(middle)
//
//    print("isPalindrome:", checkPalindrome(node0, reversed))
    
    
    //    print(isPalindrome(node0))
    func maxUncrossedLines(_ nums1: [Int], _ nums2: [Int]) -> Int {
      
//      //Define 2 dimensional array
//      var dp = Array(repeating: Array(repeating: 0,
//                                      count: nums2.count + 1),
//                     count: nums1.count + 1)
      var prev = Array(repeating: 0, count: nums2.count+1)
      
      //Dynamic programming
      for i in 1...nums1.count {
        var new = Array(repeating: 0, count: nums2.count+1)
        for j in 1...nums2.count {
          if nums1[i-1] == nums2[j-1] {
            new[j] = 1 + new[j-1]
          } else {
            new[j] = max(prev[j],
                         new[j-1])
          }
        }
        prev = new
      }
      
//      return dp[nums1.count][nums2.count]
      return prev[nums2.count]
//      var memo = [[Int: Int]: Int]()
//      var calls = 0 {
//        didSet {
//          print("calls", calls)
//        }
//      }
//
//      func dfs(i: Int, j: Int) -> Int {
//        calls = calls + 1
//        //Check if out of bounds
//        if i == nums1.count || nums2.count == j {
//          return 0
//        }
//
//        if let found = memo[[i:j]] {
//          return found
//        }
//
//        //Recursion cases
//        if nums1[i] == nums2[j] {
//          //Check match
//          let next = dfs(i: i + 1, j: j + 1)
//          memo[[i:j]] = 1 + next
//        } else {
//          let first = dfs(i: i, j: j + 1)
//          let second = dfs(i: i + 1, j: j)
//          memo[[i:j]] = max(first, second)
//        }
//        return memo[[i:j]]!
//      }
//
//      return dfs(i: 0, j: 0)
      
      
//      //Array of arrays
//      var dp = Array(repeating: Array(repeating: 0,
//                                      count: nums2.count + 1),
//                     count: nums1.count + 1)
//
//      for i in 1...nums1.count {
//        print("nums1:", nums1[i-1])
//        for j in 1...nums2.count {
//          print("nums1:", nums2[j-1])
//          if nums1[i-1] == nums2[j-1] {
//            //dp[nums1][nums2] =
//            dp[i][j] = 1 + dp[i-1][j-1]
//          }else{
//            dp[i][j] = max(dp[i-1][j], dp[i][j-1])
//          }
//        }
//      }
//
//      return dp[nums1.count][nums2.count]
      return 0
    }
    
    print(maxUncrossedLines([5,4,2,9], [5,1,2,9]))
  }
}
