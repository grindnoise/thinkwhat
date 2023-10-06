//
//  URL.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

extension URL {
  var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
  var isMP3: Bool { typeIdentifier == "public.mp3" }
  var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
  var hasHiddenExtension: Bool {
    get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
    set {
      var resourceValues = URLResourceValues()
      resourceValues.hasHiddenExtension = newValue
      try? setResourceValues(resourceValues)
    }
  }
}
