//
//  Publisher.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Combine
import Foundation

extension Publisher {
  /// Attaches the specified subscriber to this publisher.
  ///
  /// Implementations of ``Publisher`` must implement this method.
  ///
  /// The provided implementation of ``Publisher/subscribe(_:)-4u8kn``calls this method.
  ///
  /// - Parameter subscriber: The subscriber to attach to this ``Publisher``, after which it can receive values.
  func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
    compactMap { $0 }
  }
}

struct DispatchTimerConfiguration {
  let queue: DispatchQueue?
  let interval: DispatchTimeInterval
  let leeway: DispatchTimeInterval
  let times: Subscribers.Demand
}

extension Publishers {
  struct DispatchTimer: Publisher {
    typealias Output = DispatchTime
    typealias Failure = Never
    
    let configuration: DispatchTimerConfiguration
    
    init(configuration: DispatchTimerConfiguration) {
      self.configuration = configuration
    }
    
    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      let subscription = DispatchTimerSubscription(subscriber: subscriber,
                                                   configuration: configuration)
      subscriber.receive(subscription: subscription)
    }
  }
}

private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {
  //comes from subscriber
  let configuration: DispatchTimerConfiguration
  //The maximum number of times the timer will fire, which you copied from the configuration. You’ll use it as a counter that you decrement every time you send a value
  var times: Subscribers.Demand
  //The current demand; e.g., the number of values the subscriber requested — you decrement it every time you send a value
  var requested: Subscribers.Demand = .none
  //Internal Source timer that will generate events
  var source: DispatchSourceTimer? = nil
  //The subscriber. This makes it clear that the subscription is responsible for retaining the subscriber for as long as it doesn’t complete, fail or cancel
  var subscriber: S?
  
  init(subscriber: S, configuration: DispatchTimerConfiguration) {
    self.configuration = configuration
    self.subscriber = subscriber
    self.times = configuration.times
  }
  
  func cancel() {
    self.subscriber = nil
    self.source = nil
  }
  
  func request(_ demand: Subscribers.Demand) {
    guard times > .none else {
      subscriber?.receive(completion: .finished)
      return
    }
    
    requested += demand
    
    if source == nil, requested > .none {
      source = DispatchSource.makeTimerSource(queue: configuration.queue)
      source?.schedule(deadline: .now() + configuration.interval,
                       repeating: configuration.interval,
                       leeway: configuration.leeway)
      
      source?.setEventHandler { [weak self] in
        guard let self = self,
        self.requested > .none
        else { return }
        
        self.requested -= .max(1)
        self.times -= .max(1)
        self.subscriber?.receive(.now())
        
        guard self.times == .none else { return }
        
        self.subscriber?.receive(completion: .finished)
      }
      source?.activate()
    }
  }
}

extension Publishers {
  static func timer(queue: DispatchQueue? = nil,
                    interval: DispatchTimeInterval,
                    leeway: DispatchTimeInterval = .nanoseconds(0),
                    times: Subscribers.Demand = .unlimited) -> Publishers.DispatchTimer {
    
    return Publishers.DispatchTimer(configuration: DispatchTimerConfiguration(queue: queue,
                                                                              interval: interval,
                                                                              leeway: leeway,
                                                                              times: times))
  }
}
