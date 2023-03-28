//
//  UIImage.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//



import UIKit

extension UIImage {
  /**
   Returns a new grayscaled image
   */
  func setFilter(filter: String) -> UIImage? {
    let context = CIContext(options: nil)
    guard let currentFilter = CIFilter(name: filter) else { return nil }
    currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
    if let output = currentFilter.outputImage,
       let cgImage = context.createCGImage(output, from: output.extent) {
      return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    return nil
  }
}
