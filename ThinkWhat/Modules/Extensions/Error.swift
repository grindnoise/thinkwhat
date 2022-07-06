//
//  Error.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

extension Error {
    func printLocalized(class _class: AnyClass?, functionName: String?) {
        guard !functionName.isNil else {
            print(self.localizedDescription)
            return
        }
        guard !_class.isNil else {
            print("\(functionName!) threw error: \(self.localizedDescription)")
            return
        }
        print("\(String(describing: _class!)).\(functionName!) threw error: \(self.localizedDescription)")
    }
}
