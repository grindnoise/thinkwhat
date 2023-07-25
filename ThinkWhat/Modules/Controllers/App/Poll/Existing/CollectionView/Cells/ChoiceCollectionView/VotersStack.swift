//
//  VotersStack.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class VotersStack: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  ///`Publishers`
  public let tapPublisher = PassthroughSubject<Bool, Never>()
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Logic`
  ///For limiting avatars in stack
  private let capacity: Int
  private var stack: Stack<Avatar>
  ///`UI`
  private var lightBorderColor: UIColor
  private var darkBorderColor: UIColor
  private let height: CGFloat
  private var intersection: CGFloat { height * 1/3 }
  private lazy var listener: UIView = {
    let opaque = UIView.opaque()
    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    opaque.layer.zPosition = 100
    
    return opaque
  }()
  
  
  
  // MARK: - Deinitialization
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  init(userprofiles: [Userprofile],
       capacity: Int,
       lightBorderColor: UIColor,
       darkBorderColor: UIColor,
       height: CGFloat
  ) {
    self.height = height
    self.lightBorderColor = lightBorderColor
    self.darkBorderColor = darkBorderColor
    self.capacity = capacity
    stack = Stack(capacity: capacity)
    
    super.init(frame: .zero)
    
//    userprofiles.forEach {
//      stack.push(Avatar(userprofile: $0,
//                        isBordered: true,
//                        lightBorderColor: lightBorderColor,
//                        darkBorderColor: darkBorderColor)) }
    setupUI()
    push(userprofiles: userprofiles)
  }
  
  override init(frame: CGRect) {
    fatalError("init(coder:) has not been implemented")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func push(userprofiles: [Userprofile]) {
    func push(_ instances: [Userprofile]) {
      instances.forEach { userprofile in
        let pushed = Avatar(userprofile: userprofile,
                            isBordered: true,
                            lightBorderColor: lightBorderColor,
                            darkBorderColor: darkBorderColor)
        
        guard stack.storage.filter({ $0.userprofile == userprofile }).isEmpty else { return }
        
        if subviews.filter({ $0 is Avatar }).isEmpty {
//          addSubview(pushed)
          insertSubview(pushed, belowSubview: listener)
          pushed.translatesAutoresizingMaskIntoConstraints = false
          pushed.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
          pushed.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
          let constraint = pushed.trailingAnchor.constraint(equalTo: trailingAnchor)
          constraint.identifier = "anchor"
          constraint.isActive = true
        } else if let last = subviews.filter({ $0 is Avatar }).last {
//          addSubview(pushed)
          insertSubview(pushed, belowSubview: listener)
          pushed.translatesAutoresizingMaskIntoConstraints = false
          pushed.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
          pushed.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
          let constraint = pushed.trailingAnchor.constraint(equalTo: last.leadingAnchor, constant: intersection)
          constraint.identifier = "anchor"
          constraint.isActive = true
        }
        
        if let popped = stack.push(pushed) {
          
          var peak: UIView?
          
          if stack.storage.count > 1 {
            peak = stack.peek()
          }
          popped.removeFromSuperview()
          
          guard let peak = peak,
                let peakConstraint = peak.getConstraint(identifier: "anchor")
          else { return }
          
          
          setNeedsLayout()
          peak.removeConstraint(peakConstraint)
          let new = peak.trailingAnchor.constraint(equalTo: trailingAnchor)
          new.identifier = "anchor"
          new.isActive = true
          layoutIfNeeded()
        }
      }
    }
    
    func push(_ instance: Userprofile) {
      let pushed = Avatar(userprofile: instance,
                          isBordered: true,
                          lightBorderColor: lightBorderColor,
                          darkBorderColor: darkBorderColor)
      
      if subviews.filter({ $0 is Avatar }).isEmpty {
//        addSubview(pushed)
        insertSubview(pushed, belowSubview: listener)
        pushed.translatesAutoresizingMaskIntoConstraints = false
        pushed.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        let constraint = pushed.trailingAnchor.constraint(equalTo: trailingAnchor)
        constraint.identifier = "anchor"
        constraint.isActive = true
      } else if let last = subviews.filter({ $0 is Avatar }).last as? Avatar {
//        addSubview(pushed)
        insertSubview(pushed, belowSubview: listener)
        pushed.translatesAutoresizingMaskIntoConstraints = false
        pushed.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        let constraint = pushed.trailingAnchor.constraint(equalTo: last.leadingAnchor, constant: intersection)
        constraint.identifier = "anchor"
        constraint.isActive = true
      }
      
        pushed.transform = .init(scaleX: 0.5, y: 0.5)
        pushed.alpha = 0
        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          usingSpringWithDamping: 0.9,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut]) {
            pushed.alpha = 1
            pushed.transform = .identity
          }
      
      if let popped = stack.push(pushed),
         let constraint = popped.getConstraint(identifier: "anchor") {
        
        var peak: UIView?
        
        if stack.storage.count > 1 {
          peak = stack.peek()
        }
        
        setNeedsLayout()
        
        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          usingSpringWithDamping: 0.9,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut],
          animations: { [weak self] in
            guard let self = self else { return }
            
            constraint.constant = self.height - self.intersection
            self.layoutIfNeeded()
            popped.alpha = 0
            popped.transform = .init(scaleX: 0.5, y: 0.5)
          }) { [weak self] _ in
            guard let self = self else { return }
            
            popped.removeFromSuperview()
            
            guard let peak = peak,
                  let peakConstraint = peak.getConstraint(identifier: "anchor")
            else { return }


            self.setNeedsLayout()
            peak.removeConstraint(peakConstraint)
            let new = peak.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            new.identifier = "anchor"
            new.isActive = true
            self.layoutIfNeeded()
          }
      }
    }
    
    let currentSet = Set(stack.storage.compactMap { $0.userprofile })
//    let appendingSet = Set(userprofiles)
//    let appendingArray = Array(appendingSet.symmetricDifference(currentSet))
    
    let newSet = Set(userprofiles)
    
    guard !currentSet.isEmpty else {
      push(Array(newSet))
      return
    }
    
    let appendingSet = newSet.subtracting(currentSet)
//    newSet.map { $0.id }
//    currentSet.map { $0.id }
//    appendingSet.map { $0.id }
    guard !appendingSet.isEmpty else { return }
    
    appendingSet.count > 1 ? push(Array(appendingSet)) : push(appendingSet.first!)
  }
      
  public func setColors(lightBorderColor: UIColor,
                        darkBorderColor: UIColor) {
    self.lightBorderColor = lightBorderColor
    self.darkBorderColor = darkBorderColor
    
    stack.storage.forEach {
      $0.lightBorderColor = lightBorderColor
      $0.darkBorderColor = darkBorderColor
    }
  }
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension VotersStack {
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    listener.addEquallyTo(to: self)
    
    ///Intersection by 1/3
    let constraint = widthAnchor.constraint(equalTo: heightAnchor,
                                            multiplier: CGFloat(Double(capacity)-0.5))// - 1))
    constraint.constant = -intersection/2//(36)*(1/3)
    constraint.isActive = true
    //*0.7).isActive = true
//
//    stack.storage.reversed().forEach { avatar in
//      if subviews.filter({ $0 is Avatar }).isEmpty {
//        insertSubview(avatar, belowSubview: listener)
////        addSubview(avatar)
//        avatar.translatesAutoresizingMaskIntoConstraints = false
//        avatar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
//        let constraint = avatar.trailingAnchor.constraint(equalTo: trailingAnchor)
//        constraint.identifier = "anchor"
//        constraint.isActive = true
//
//      } else if let last = subviews.last as? Avatar {
////        addSubview(avatar)
//        insertSubview(avatar, belowSubview: listener)
//        avatar.translatesAutoresizingMaskIntoConstraints = false
//        avatar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
//        let constraint = avatar.trailingAnchor.constraint(equalTo: last.leadingAnchor, constant: intersection)
//        constraint.identifier = "anchor"
//        constraint.isActive = true
//      }
//    }
  }
  
  @objc
  func handleTap() {
    tapPublisher.send(true)
  }
}

