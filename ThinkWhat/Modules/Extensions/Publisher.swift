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

//Exmaple
//var logger = TimeLogger(sinceOrigin: true)
//
//let publisher = Publishers.timer(interval: .seconds(1), times: .max(6))
//
//let subscription = publisher.sink {
//  print("rawValue: \($0)", to: &logger)
//}
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//  subscription.cancel()
//}

// 1
fileprivate final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
  // 2
  let capacity: Int
  // 3
  var subscriber: AnySubscriber<Output,Failure>? = nil
  // 4
  var demand: Subscribers.Demand = .none
  //Хранилище значений
  var buffer: [Output]
  // 6
  var completion: Subscribers.Completion<Failure>? = nil

  init<S>(subscriber: S,
          replay: [Output],
          capacity: Int,
          completion: Subscribers.Completion<Failure>?)
          where S: Subscriber,
                Failure == S.Failure,
                Output == S.Input {
    // 7
    self.subscriber = AnySubscriber(subscriber)
    // 8
    self.buffer = replay
    self.capacity = capacity
    self.completion = completion
  }

  private func complete(with completion: Subscribers.Completion<Failure>) {
    // 9
    guard let subscriber = subscriber else { return }
    self.subscriber = nil
    // 10
    self.completion = nil
    self.buffer.removeAll()
    // 11
    subscriber.receive(completion: completion)
  }

  private func emitAsNeeded() {
    guard let subscriber = subscriber else { return }
    //Пока требуется получение значения и буфер не пуст
    while self.demand > .none && !buffer.isEmpty {
      //Уменьшаем спрос потребителя на 1 значение
      self.demand -= .max(1)
      //Передаем подписчику значение, выброшенное стеком
      let nextDemand = subscriber.receive(buffer.removeFirst())
      // 15
      if nextDemand != .none {
        self.demand += nextDemand
      }
    }
    // 16
    if let completion = completion {
      complete(with: completion)
    }
  }

  func request(_ demand: Subscribers.Demand) {
    if demand != .none {
      self.demand += demand
    }
    emitAsNeeded()
  }

  func receive(_ input: Output) {
    guard subscriber != nil else { return }
    //Добавляем в хранилище значений полученный от publisher элемент
    buffer.append(input)
    if buffer.count > capacity {
      //Если буфер значений переполнен, то выкидываем первый элемент стека
      buffer.removeFirst()
    }
    //Принудительно передаем данные хранилища
    emitAsNeeded()
  }

  func receive(completion: Subscribers.Completion<Failure>) {
    guard let subscriber = subscriber else { return }
    self.subscriber = nil
    self.buffer.removeAll()
    subscriber.receive(completion: completion)
  }

  func cancel() {
    complete(with: .finished)
  }
}

extension Publishers {
  // 20
  final class ShareReplay<Upstream: Publisher>: Publisher {
    // 21
    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure

    // 22
    private let lock = NSRecursiveLock()
    // 23
    private let upstream: Upstream
    // 24
    private let capacity: Int
    //Хранилищу полученных от publisher значений
    private var replay = [Output]()
    // 26
    private var subscriptions = [ShareReplaySubscription<Output, Failure>]()
    // 27
    private var completion: Subscribers.Completion<Failure>? = nil

    init(upstream: Upstream, capacity: Int) {
      self.upstream = upstream
      self.capacity = capacity
    }

    func receive<S: Subscriber>(subscriber: S)
      where Failure == S.Failure,
            Output == S.Input {
      lock.lock()
      defer { lock.unlock() }

      // 34
      let subscription = ShareReplaySubscription(
        subscriber: subscriber,
        replay: replay,
        capacity: capacity,
        completion: completion)

      // 35
      subscriptions.append(subscription)
      // 36
      subscriber.receive(subscription: subscription)

      // 37
      guard subscriptions.count == 1 else { return }
      //Реле-транслятор. Транслирует всем подписками текущее значение publisher
      let sink = AnySubscriber(
        // 39
        receiveSubscription: { subscription in
          //Подписка требует бесконечных данных
          subscription.request(.unlimited)
        },
        receiveValue: { [weak self] (value: Output) -> Subscribers.Demand in
            self?.relay(value)//Транслируется значение 
            return .none
          },
          receiveCompletion: { [weak self] in
            self?.complete($0)
        }
      )

      upstream.subscribe(sink)
    }

    private func relay(_ value: Output) {
      // 28
      lock.lock()
      defer { lock.unlock() }

      // 29
      guard completion == nil else { return }

      //Добавляем в хранилище значение и проверяем, чтобы емкость хранилища не превышала установленного порога, иначе выкидываем из стека первое значение
      replay.append(value)
      if replay.count > capacity {
        print(String(describing: replay.count))
        replay.removeFirst()
      }
      //Заставляем подписку передать подписчику текущее значение
      subscriptions.forEach {
        $0.receive(value)
      }
    }

    private func complete(_ completion: Subscribers.Completion<Failure>) {
      lock.lock()
      defer { lock.unlock() }
      // 32
      self.completion = completion
      // 33
      subscriptions.forEach {
        $0.receive(completion: completion)
      }
    }
  }
}

extension Publisher {
  func shareReplay(capacity: Int = .max) -> Publishers.ShareReplay<Self> {
    return Publishers.ShareReplay(upstream: self, capacity: capacity)
  }
}


