//
//  Complaintable.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import Combine

protocol Complaintable: Hashable {
  var id: Int { get }
  var isClaimedPublisher: PassthroughSubject<Bool, Error> { get }
}
