//
//  LanguageCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine
import TinyConstraints

class LanguageCell: UICollectionViewListCell {

  // MARK: - Public properties
  public var item: LanguageItem! {
    didSet {
      guard !item.isNil else { return }
      
      updateUI()
    }
  }
  ///**UI**
  public var insets: UIEdgeInsets = .zero// .uniform(Constants.UI.padding)
  ///**Publishers**
  public var selectionPublisher = PassthroughSubject<Void, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var textField: InsetTextField = {
    let instance = InsetTextField(rightViewVerticalScaleFactor: 1.25,
                                  insets: .uniform(Constants.UI.padding))
    
    let sign = UIImageView(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!)
    sign.tintColor = Constants.UI.Colors.deselected
    sign.contentMode = .center
    instance.rightView = sign
    instance.isUserInteractionEnabled = false
    instance.text = "Test"
    instance.rightViewMode = .always
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = .clear // Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection)
    
    return instance
  }()
//  private lazy var btn: UIButton = {
//    let instance = UIButton()
//    instance.setTitle("", for: .normal)
//    
//    return instance
//  }()
  
  // MARK: - Destructor
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
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
    
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if #unavailable(iOS 17) {
      updateTraits()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    // Reset item
    item = nil
    // Reset publishers
    selectionPublisher = PassthroughSubject<Void, Never>()
    // Reset sign
    setSign(active: false)
  }
}

private extension LanguageCell {
  @MainActor
  func setupUI() {
    layer.masksToBounds = true
    contentView.layer.masksToBounds = true
    contentView.addSubview(textField)
    textField.edgesToSuperview(insets: insets)
    
//    contentView.addSubview(btn)
//    btn.edgesToSuperview()
//    btn.addTarget(self, action: #selector(self.selectLocale), for: .touchUpInside)

    
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
  }
  
  @MainActor
  func updateUI() {
    textField.text = Locale(identifier: item.code).localizedString(forIdentifier: item.code)?.capitalized
    setSign(active: item.selected)
    
    if let opaque = contentView.getSubview(type: UIView.self, identifier: "opaque") {
      opaque.removeFromSuperview()
    }
    
    let opaque = UIView.opaque()
    opaque.isUserInteractionEnabled = true
    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectLocale)))
    contentView.addSubview(opaque)
    opaque.edgesToSuperview()
  }
  
  @objc
  func updateTraits() {
//    textField.backgroundColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection)
  }
  
  @objc
  func selectLocale() {
    item.selected = !item.selected
    setSign(active: item.selected)
    selectionPublisher.send()
  }
  
  func setSign(active: Bool) {
    guard let sign = textField.rightView as? UIImageView else { return }
        
    UIView.animate(withDuration: 0.15) {
      sign.tintColor = active ? .systemGreen : Constants.UI.Colors.deselected
    }
  }
}

