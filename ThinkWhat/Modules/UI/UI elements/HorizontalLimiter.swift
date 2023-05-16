//
//  HorizontalLimiter.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class HorizontalLimiter: UIView {
  
  enum Alignment: String { case Top, Middle, Bottom }
  
  ///**UI**
  private let alignment: Alignment
  private let line = Line()
  private let lineColor: UIColor
  private let lineWidth: CGFloat
  
  init(alignment: Alignment,
       lineColor: UIColor,
       lineWidth: CGFloat
  ) {
    self.alignment = alignment
    self.lineColor = lineColor
    self.lineWidth = lineWidth
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }
  
  //  required init?(coder: NSCoder) {
  //    fatalError("init(coder:) has not been implemented")
  //  }
  required init?(coder aDecoder: NSCoder) {
    guard let frame = aDecoder.decodeCGRect(forKey: "frame") as? CGRect,
          let lineColor = aDecoder.decodeObject(forKey: "lineColor") as? Data,
          let lineWidth = aDecoder.decodeDouble(forKey: "lineWidth") as? Double,
          let alignmentStr = aDecoder.decodeObject(forKey: "alignment") as? String,
          let alignment = Alignment(rawValue: alignmentStr)
    else { return nil }
    
    do {
      self.lineColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: lineColor) ?? .label
      self.lineWidth = CGFloat(lineWidth)
      self.alignment = alignment
      
      super.init(frame: frame)
      
      setupUI()
      
    } catch {
      return nil
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
   
    updateUI()
  }
  
  override func encode(with aCoder: NSCoder) {
    aCoder.encode(alignment.rawValue, forKey: "alignment")
    do {
      let colorData = try NSKeyedArchiver.archivedData(withRootObject: lineColor, requiringSecureCoding: false)
      aCoder.encode(colorData, forKey: "lineColor")
    } catch {
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
    }
    aCoder.encode(frame, forKey: "frame")
    aCoder.encode(Double(lineWidth), forKey: "lineWidth")
  }
}

private extension HorizontalLimiter {
  @MainActor
  func setupUI() {
    layer.addSublayer(line.layer)
    
    line.layer.fillColor = lineColor.cgColor
    line.layer.strokeColor = lineColor.cgColor
    updateUI()
  }
  
  @MainActor
  func updateUI() {
    line.path = UIBezierPath()
    
    var y: CGFloat = 0
    switch alignment {
    case .Top:
      y = 0
    case .Middle:
      y = frame.height/2 - line.layer.lineWidth / 2
    case .Bottom:
      y = frame.height - line.layer.lineWidth / 2
    }
    
    let startPoint = CGPoint(x: 0, y: y)
    line.path.move(to: startPoint)
    
    let endPoint = CGPoint(x: frame.width, y: y)
    line.path.addLine(to: endPoint)
    line.layer.path = line.path.cgPath
  }
}
