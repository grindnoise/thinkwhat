//
//  TimeoutTask.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class TimeoutTask<Success> {
    let nanoseconds: UInt64
    let operation: @Sendable () async throws -> Success
    
    init(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> Success
    ) {
        self.nanoseconds = UInt64(seconds * 1_000_000_000)
        self.operation = operation
    }
    
    private var continuation: CheckedContinuation<Success, Error>?
    
    var value: Success {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                Task {
                    try await Task.sleep(nanoseconds: nanoseconds)
                    cancel()
                    self.continuation?.resume(throwing: TimeoutError())
                    self.continuation = nil
                }
                Task {
                    let result = try await operation()
                    self.continuation?.resume(returning: result)
                    self.continuation = nil
                }
            }
        }
    }
    func cancel() {
        continuation?.resume(throwing: CancellationError())
        continuation = nil
    }
}

extension TimeoutTask {
  struct TimeoutError: LocalizedError {
    var errorDescription: String? {
      return "The operation timed out."
    }
  }
}
