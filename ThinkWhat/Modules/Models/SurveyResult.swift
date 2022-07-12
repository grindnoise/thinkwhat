//
//  SurveyResult.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class SurveyResult {
    let choice: Answer
    var isPopular: Bool = false
    var points: Int?
    
    init(choice: Answer) {
        self.choice = choice
    }
}
