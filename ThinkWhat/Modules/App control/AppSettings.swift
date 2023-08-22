//
//  AppSettings.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

struct AppSettings {
  struct TimeIntervals {
    static let updateStatsComments = 10.0
    static let updateStats = 10.0
    static let requestPublications = 5.0
  }
  
  struct Pagination {
    static let threshold = 10 // To request new chunk of data when sroll near list end
  }
}
