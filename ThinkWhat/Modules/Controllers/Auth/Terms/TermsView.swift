//
//  TermsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import WebKit

class TermsView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: (TermsViewInput & UIViewController)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  ///**UI**
  public private(set) lazy var webView: WKWebView = {
    let instance = WKWebView()
    instance.isOpaque = false
    instance.backgroundColor = .clear
    instance.scrollView.isScrollEnabled = false
    instance.scrollView.delegate = self
    instance.navigationDelegate = self
    
    return instance
  }()
  public private(set) lazy var acceptButton: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = .systemGray
      config.attributedTitle = AttributedString("acceptButton".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.clear as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = .systemGray
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "acceptButton".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: UIColor.clear as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
  }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let padding: CGFloat = 8
  private var agreementIsLoading = true {
    didSet {
      guard !agreementIsLoading else { return }
      
      webView.scrollView.isScrollEnabled = true
    }
  }
  private var hasReadAgreement = false {
    didSet {
      if hasReadAgreement {
        if #available(iOS 15, *) {
          acceptButton.getSubview(type: UIButton.self)!.configuration?.baseBackgroundColor = Constants.UI.Colors.main
        } else {
          acceptButton.getSubview(type: UIButton.self)!.backgroundColor = Constants.UI.Colors.main
        }
      }
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TermsView: TermsControllerOutput {
  func animateTransitionToApp(_ completion: @escaping Closure) {
    guard let viewInput = viewInput,
          let titleView = viewInput.navigationController?.navigationBar.subviews.filter({ $0 is UIStackView }).first as? UIStackView,
          let titleIcon = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoIcon" }).first as? Icon,
          let titleText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoText" }).first as? Icon,
          let window = appDelegate.window
    else { completion(); return }
    
    viewInput.navigationItem.setHidesBackButton(true, animated: true)
    
    let opaque = PassthroughView()
    opaque.frame = UIScreen.main.bounds
    opaque.place(inside: window)

    let loadingIcon: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingIcon"
      instance.category = Icon.Category.Logo
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1.2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingText: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingText"
      instance.category = Icon.Category.LogoText
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingStack: UIStackView = {
      let opaque = UIView()
      opaque.backgroundColor = .clear
      
      let instance = UIStackView(arrangedSubviews: [
        opaque,
        loadingText
      ])
      instance.axis = .vertical
      instance.distribution = .equalCentering
      instance.spacing = 0
      instance.clipsToBounds = false
      
      loadingIcon.translatesAutoresizingMaskIntoConstraints = false
      opaque.translatesAutoresizingMaskIntoConstraints = false
      opaque.addSubview(loadingIcon)
      
      NSLayoutConstraint.activate([
        loadingIcon.topAnchor.constraint(equalTo: opaque.topAnchor),
        loadingIcon.bottomAnchor.constraint(equalTo: opaque.bottomAnchor),
        loadingIcon.centerXAnchor.constraint(equalTo: opaque.centerXAnchor),
        opaque.heightAnchor.constraint(equalTo: loadingText.heightAnchor, multiplier: 2)
      ])
      
      return instance
    }()
    loadingStack.placeInCenter(of: opaque,
                               widthMultiplier: 0.6)
        opaque.setNeedsLayout()
        opaque.layoutIfNeeded()
    
    ///Fake icons to animate
    let fakeLogoIcon: Icon = {
      let instance = Icon(frame: CGRect(origin: titleIcon.superview!.convert(titleIcon.frame.origin,
                                                                            to: opaque),
                                        size: titleIcon.bounds.size))
      instance.category = Icon.Category.Logo
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1.2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
      
      return instance
    }()
    let fakeLogoText: Icon = {
      let instance = Icon(frame: CGRect(origin: titleText.superview!.convert(titleText.frame.origin,
                                                                            to: opaque),
                                        size: titleText.bounds.size))
      
      instance.category = Icon.Category.LogoText
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
      
      return instance
    }()
    let fakeAcceptButton: UIButton = {
      let instance = UIButton(frame: CGRect(origin: acceptButton.superview!.convert(acceptButton.frame.origin,
                                                                                 to: opaque),
                                             size: acceptButton.bounds.size))
      if #available(iOS 15, *) {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = Constants.UI.Colors.main
        config.attributedTitle = AttributedString("acceptButton".localized,
                                                  attributes: AttributeContainer([
                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                    .foregroundColor: UIColor.white as Any
                                                  ]))
        instance.configuration = config
      } else {
        instance.cornerRadius = acceptButton.cornerRadius
        instance.setAttributedTitle(NSAttributedString(string: "acceptButton".localized,
                                                       attributes: [
                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                        .foregroundColor: UIColor.white as Any
                                                       ]),
                                    for: .normal)
        instance.backgroundColor = Constants.UI.Colors.main
      }
      
      
      return instance
    }()
    
//    fakeLogoIcon.frame = CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
//                                                                to: opaque),
//                            size: logoIcon.bounds.size)
//    fakeLogoText.frame = CGRect(origin: logoText.superview!.convert(logoText.frame.origin,
//                                                                to: opaque),
//                            size: logoText.bounds.size)
//
    opaque.addSubviews([fakeLogoIcon, fakeLogoText, fakeAcceptButton])
//    opaque.setNeedsLayout()
//    opaque.layoutIfNeeded()
    acceptButton.alpha = 0
    titleIcon.alpha = 0
    titleText.alpha = 0
    
//    print("opaque.frame", opaque.frame)
//    print("loadingStack.frame", loadingStack.frame)
    
//    fakeLogoIcon.icon.add(Animations.get(property: .FillColor,
//                                        fromValue: Colors.main.cgColor as Any,
//                                         toValue: Colors.Logo.Flame.next().rawValue.cgColor as Any,
//                                        duration: 0.3,
//                                        delay: 0,
//                                        repeatCount: 0,
//                                        autoreverses: false,
//                                        timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                                        delegate: nil,
//                                        isRemovedOnCompletion: false),
//                         forKey: nil)
//    fakeLogoText.icon.add(Animations.get(property: .FillColor,
//                                        fromValue: Colors.main.cgColor as Any,
//                                         toValue: Colors.Logo.Flame.next().rawValue.cgColor as Any,
//                                        duration: 0.3,
//                                        delay: 0,
//                                        repeatCount: 0,
//                                        autoreverses: false,
//                                        timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                                        delegate: self,
//                                        isRemovedOnCompletion: false,
//                                        completionBlocks: []),
//                         forKey: nil)
    fakeLogoIcon.icon.add(Animations.get(property: .Path,
                                     fromValue: (fakeLogoIcon.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingIcon.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false),
                      forKey: nil)
    fakeLogoText.icon.add(Animations.get(property: .Path,
                                     fromValue: (fakeLogoText.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingText.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false),
                      forKey: nil)

    
    
    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.3,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }
      
      self.webView.alpha = 0
      self.webView.transform = .init(scaleX: 0.5, y: 0.5)
      fakeAcceptButton.frame.origin.y = opaque.bounds.height
      fakeLogoIcon.frame = CGRect(origin: loadingStack.convert(loadingIcon.frame.origin,
                                                                      to: opaque),
                                  size: loadingIcon.bounds.size)
      fakeLogoText.frame = CGRect(origin: loadingStack.convert(loadingText.frame.origin,
                                                                      to: opaque),
                                  size: loadingText.bounds.size)
      
    }) { _ in
      loadingIcon.alpha = 1
      loadingText.alpha = 1
      fakeLogoText.removeFromSuperview()
      fakeLogoIcon.removeFromSuperview()
      completion()
    }
  }
  
  func getTermsConditionsURL(_ url: URL) {
    webView.load(URLRequest(url: url))
  }
}

private extension TermsView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    acceptButton.setSpinning(on: true, color: .white, animated: false)
    
    
    let opaque = UIView.opaque()
    acceptButton.placeInCenter(of: opaque,
                              topInset: padding,
                              bottomInset: padding)
    
    let stack = UIStackView(arrangedSubviews: [
      webView,
      opaque,
      UIView.verticalSpacer(padding*2)
    ])
    stack.axis = .vertical
    stack.spacing = padding
    stack.place(inside: self)
    
    acceptButton.translatesAutoresizingMaskIntoConstraints = false
    acceptButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
  }
  
  @objc
  func handleTap(_ sender: UIButton) {
    if agreementIsLoading {
      let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                            text: "wait_for_agreement".localized,
                                                            tintColor: .systemOrange,
                                                            fontName: Fonts.Regular,
                                                            textStyle: .subheadline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &subscriptions)
    } else {
      switch hasReadAgreement {
      case true:
        viewInput?.onAccept()
      case false:
        let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "should_read_agreement_message".localized,
                                                              tintColor: .systemOrange,
                                                              fontName: Fonts.Regular,
                                                              textStyle: .subheadline,
                                                              textAlignment: .natural),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &subscriptions)
      }
    }
  }
}

// MARK: - Web delegate
extension TermsView: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    agreementIsLoading = false
    acceptButton.setSpinning(on: false, color: .white, animated: true) {[weak self] in
      guard let self = self else { return }
      
      if #available(iOS 15, *) {
        self.acceptButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString("acceptButton".localized,
                                                                                                             attributes: AttributeContainer([
                                                                                                              .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                              .foregroundColor: UIColor.white as Any
                                                                                                             ]))
      } else {
        self.acceptButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: "acceptButton".localized,
                                                                                                 attributes: [
                                                                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                  .foregroundColor: UIColor.white as Any
                                                                                                 ]),
                                                                              for: .normal)
      }
    }
  }
}

// MARK: - Scroll delegate
extension TermsView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.isScrollEnabled, !hasReadAgreement, (scrollView.contentOffset.y + scrollView.bounds.height) >= scrollView.contentSize.height {
      hasReadAgreement = true
    }
  }
}
extension TermsView: CAAnimationDelegate {}
