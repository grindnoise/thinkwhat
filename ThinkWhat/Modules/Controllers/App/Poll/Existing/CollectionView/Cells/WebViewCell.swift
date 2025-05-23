//
//  WebViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import WebKit
import Combine

class WebViewCell: UICollectionViewCell {
  
  // MARK: - Overriden properties
  override var isSelected: Bool { didSet { updateAppearance() } }
  
  // MARK: - Public Properties
  var item: Survey! {
    didSet {
      guard !item.isNil, let url = item.url else { return }
      color = item.topic.tagColor
      if url.absoluteString.isTikTokLink, isTiTokInstalled {
        app = .TikTok
        opaqueView = UIView(frame: .zero)
        opaqueView!.backgroundColor = .clear
        opaqueView!.addEquallyTo(to: contentView)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(WebViewCell.viewTapped(recognizer: )))
        opaqueView!.addGestureRecognizer(recognizer)
      }
      do {
        try webView.load(URLRequest(url: url, method: .get))
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  public weak var callbackDelegate: CallbackObservable?
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private var isTiTokInstalled: Bool {
    let appName = "tiktok"
    let appScheme = "\(appName)://app"
    let appUrl = URL(string: appScheme)
    return UIApplication.shared.canOpenURL(appUrl! as URL)
  }
  private var app: Enums.ThirdPartyApp  = .Null
  private var opaqueView: UIView?
  private lazy var background: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "bg"
    instance.layer.masksToBounds = false
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
    instance.addEquallyTo(to: shadowView)
    observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
      guard let value = change.newValue else { return }
      view.cornerRadius = max(value.height, value.width) * 0.05
    })
    return instance
  }()
  private lazy var disclosureLabel: UILabel = {
    let instance = UILabel()
    instance.text = "web_link".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    instance.addEquallyTo(to: shadowView)
    //                let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
    //                constraint.identifier = "height"
    //                constraint.isActive = true
    return instance
  }()
  private lazy var browserButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "safari.fill"), for: .normal)
    instance.tintColor = .systemBlue
    instance.addTarget(self, action: #selector(WebViewCell.openURL), for: .touchUpInside)
    instance.translatesAutoresizingMaskIntoConstraints = false
    webView.addSubview(instance)
    NSLayoutConstraint.activate([
      instance.widthAnchor.constraint(equalToConstant: 40),
      instance.heightAnchor.constraint(equalToConstant: 40),
      instance.bottomAnchor.constraint(equalTo: webView.bottomAnchor, constant: -20),
      instance.trailingAnchor.constraint(equalTo: webView.trailingAnchor, constant: -20),
    ])
    instance.contentVerticalAlignment = .fill
    instance.contentHorizontalAlignment = .fill
    instance.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let disclosureIndicator = UIImageView()
    disclosureIndicator.image = UIImage(systemName: "chevron.down")
    disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    disclosureIndicator.contentMode = .center
    disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
    disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    return disclosureIndicator
  }()
  private lazy var icon: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "link",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: "1".height(withConstrainedWidth: 100,
                                                                                                                   font: disclosureLabel.font)*0.75)))
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    instance.contentMode = .center
    
    return instance
  }()
  // Stacks
  private lazy var horizontalStack: UIStackView = {
    let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
    rootStack.alignment = .center
    rootStack.distribution = .fillProportionally
    let constraint = rootStack.heightAnchor.constraint(equalToConstant: 40)
    constraint.identifier = "height"
    constraint.isActive = true
    return rootStack
  }()
  private lazy var verticalStack: UIStackView = {
    let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, shadowView])//, browserButton])
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    return verticalStack
  }()
  // Constraints
  private var closedConstraint: NSLayoutConstraint?
  private var openConstraint: NSLayoutConstraint?
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.layer.masksToBounds = false
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
    instance.layer.shadowRadius = 4
    instance.layer.shadowOffset = .zero
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1.5/1).isActive = true
    observers.append(instance.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { view, change in
      guard let value = change.newValue else { return }
      view.layer.shadowPath = UIBezierPath(roundedRect: value, cornerRadius: value.height*0.05).cgPath
    })
    return instance
  }()
  private lazy var webView: WKWebView = {
    let instance = WKWebView()
    instance.addEquallyTo(to: background)
    instance.isOpaque = false
    //        instance.uiDelegate = self
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.navigationDelegate = self
    return instance
  }()
  private let padding: CGFloat = 10
  private var tempAppPreference: Enums.SideAppPreference?
  private var sideAppPreference: Enums.SideAppPreference? {
    if UserDefaults.App.tiktokPlay == nil {
      return nil
    } else {
      return UserDefaults.App.tiktokPlay
    }
  }
  private var color: UIColor = .secondaryLabel {
    didSet {
      webView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.2)
      disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
      disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
      guard let imageView = icon.get(all: UIImageView.self).first else { return }
      imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
  }
  
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private methods
  private func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    horizontalStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
    disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
    contentView.addSubview(verticalStack)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    verticalStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
      verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
      browserButton.heightAnchor.constraint(equalToConstant: 40)
    ])
    closedConstraint = disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
    
    openConstraint = webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    openConstraint?.priority = .defaultLow
    //Наоборот, тк изначально ячейка не выбрана, а надо развернуто показать
    //        disclosureLabel.text = !isSelected ? "hide_webview".localized.uppercased() : "show_webview".localized.uppercased()
    updateAppearance()
  }
  
  private func updateAppearance() {
    closedConstraint?.isActive = isSelected
    openConstraint?.isActive = !isSelected
    
    UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
      let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
      self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
      self.shadowView.alpha = self.isSelected ? 0.5 : 1
    }
  }
  
  @objc
  private func openURL() {
    guard let url = item.url else { return }
    callbackDelegate?.callbackReceived(url as Any)
  }
  
  @objc private func viewTapped(recognizer: UITapGestureRecognizer) {
    if recognizer.state == .ended {
      switch app {
      case .TikTok:
        if sideAppPreference == .App || tempAppPreference == .App {
          if isTiTokInstalled, let url = item.url {
            UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
          }
        } else if sideAppPreference == nil, tempAppPreference == nil, isTiTokInstalled {
          
          let content = SelectSideApp(app: .TikTok)
          let banner = NewBanner(contentView: content,
                                 isModal: true)
          content.inAppPublisher
            .sink { [weak self] _ in
              guard let self = self else { return }
              
              self.tempAppPreference = .Embedded
              // TODO: - Add code
//              delayAsync(delay: 0.5) {
//                self.playerView.playVideo()
//              }
              banner.dismiss()
            }
            .store(in: &self.subscriptions)
          
          content.sideAppPublisher
            .sink { [weak self] _ in
              guard let self = self else { return }
              
              self.tempAppPreference = .App
              // TODO: - Add code
//              self.openYotubeApp()
              banner.dismiss()
            }
            .store(in: &self.subscriptions)
//          let content = SelectSideApp(app: .TikTok)
//          let banner = Banner(fadeBackground: false)

//          banner.present(content: content, dismissAfter: 0.75)
          banner.didDisappearPublisher
              .sink { _ in banner.removeFromSuperview() }
              .store(in: &self.subscriptions)
        }
      default:
        print("")
      }
    }
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
    disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    if let imageView = icon.get(all: UIImageView.self).first {
      imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
    disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                             forTextStyle: .footnote)
    guard let constraint = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
    setNeedsLayout()
    constraint.constant = max(disclosureLabel.text!.height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
    layoutIfNeeded()
  }
}

// MARK: - CallbackObservable
extension WebViewCell: CallbackObservable {
  func callbackReceived(_ sender: Any) {
    if let preference = sender as? Enums.SideAppPreference {
      opaqueView?.removeFromSuperview()
      if preference == .App {
        tempAppPreference = .App
        guard let url = item.url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
      } else {
        tempAppPreference = .Embedded
      }
    }
  }
}

// MARK: - WKUIDelegate
extension WebViewCell: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    UIView.animate(withDuration: 0.2, delay: 1, options: [.curveEaseInOut], animations: {
      self.webView.alpha = 1
    })
    //        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
    //                                   completionHandler: { (html: Any?, error: Error?) in
    //            print(html as Any)
    //        })
  }
}
