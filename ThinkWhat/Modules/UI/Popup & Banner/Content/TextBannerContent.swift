//
//  TextBannerContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TextBannerContent: UIView {
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private weak var userprofile: Userprofile!
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: image)
    instance.contentMode = .scaleAspectFit
    instance.clipsToBounds = true
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.tintColor = imageTintColor
    instance.publisher(for: \.bounds)
      .sink { [unowned self] in instance.cornerRadius = $0.width*self.cornerRadiusScaleFactor }
      .store(in: &subscriptions)
    
    if let icon = icon {
      instance.image = nil
      icon.place(inside: instance)
      icon.setIconColor(imageTintColor)
    }
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    
    instance.numberOfLines = 0
    if !attributedText.isNil {
      instance.attributedText = attributedText
    } else {
      instance.text = text.localized
      instance.textColor = textColor
      instance.textAlignment = textAlignment
      instance.font = UIFont.scaledFont(fontName: fontName, forTextStyle: textStyle)
    }
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      imageView,
      label
    ])
    instance.axis = .horizontal
    instance.alignment = .center
    instance.spacing = 8
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.15).isActive = true
    
    return instance
  }()
  private var image: UIImage?
  private let text: String
  private let imageTintColor: UIColor
  private let textColor: UIColor
  private let textStyle: UIFont.TextStyle
  private let fontName: String
  private let textAlignment: NSTextAlignment
  private var icon: Icon?
  private var attributedText: NSAttributedString?
  private let cornerRadiusScaleFactor: CGFloat
  
  
  // MARK: - Deinitialization
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  init(image: UIImage? = nil,
       icon: Icon? = nil,
       text: String,
       attributedText: NSAttributedString? = nil,
       textColor: UIColor = .label,
       tintColor: UIColor = .clear,
       fontName: String = Fonts.Rubik.Regular,
       textStyle: UIFont.TextStyle = .headline,
       textAlignment: NSTextAlignment = .natural,
       cornerRadius: CGFloat = 0) {
    self.fontName = fontName
    self.image = image
    self.icon = icon
    self.text = text
    self.attributedText = attributedText
    self.textColor = textColor
    self.textStyle = textStyle
    self.imageTintColor = tintColor
    self.textAlignment = textAlignment
    self.cornerRadiusScaleFactor = cornerRadius
    
    super.init(frame: .zero)
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension TextBannerContent {
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
  }
  
  func setTasks() {
    //        tasks.append( Task {@MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
    //                guard let self = self else { return }
    //
    //
    //            }
    //        })
  }
}


