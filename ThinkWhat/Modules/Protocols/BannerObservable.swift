//
//  BannerObservable.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol BannerObservable: class {
    func onBannerWillAppear(_ sender: Any)
    func onBannerWillDisappear(_ sender: Any)
    func onBannerDidAppear(_ sender: Any)
    func onBannerDidDisappear(_ sender: Any)
}
