//
//  EventEmitter.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class EventEmitter {
    var task: Task<Void, Never>?
    
    func emit(every milliseconds: TimeInterval) -> AsyncStream<Bool> {
        return .init { continutation in
            continutation.onTermination = { @Sendable _ in
                self.task?.cancel()
            }
            task = Task {
                while !task!.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(milliseconds * 1_000_000_000))
                    continutation.yield(true)
                }
            }
        }
    }
}
