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
  ///**UI**
  public private(set) lazy var webView: WKWebView = {
    let instance = WKWebView()
    instance.scrollView.isScrollEnabled = false
    instance.scrollView.delegate = self
    instance.navigationDelegate = self
    
    return instance
  }()
  public private(set) lazy var acceptButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(_:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = UIColor.systemGray
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.attributedTitle = AttributedString("acceptButton".localized.uppercased(),
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                  .foregroundColor: UIColor.clear as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "acceptButton".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.clear as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
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
          acceptButton.configuration?.baseBackgroundColor = Colors.main
        } else {
          acceptButton.backgroundColor = Colors.main
        }
      }
    }
  }
  
  
  
  // MARK: - Public properties
  weak var viewInput: TermsViewInput? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
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
                              topInset: 0,
                              bottomInset: 0)
    
    let stack = UIStackView(arrangedSubviews: [
    webView,
    opaque,
    UIView.verticalSpacer(padding*2)
    ])
    stack.axis = .vertical
    stack.spacing = padding
    stack.place(inside: self)
    
//    let views = [webView, acceptButton]
//    addSubviews(views)
//    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
//
//    NSLayoutConstraint.activate([
//      webView.topAnchor.constraint(equalTo: topAnchor),
//      webView.leadingAnchor.constraint(equalTo: leadingAnchor),
//      webView.trailingAnchor.constraint(equalTo: trailingAnchor),
//      acceptButton.topAnchor.constraint(equalTo: webView.bottomAnchor),
//      acceptButton.centerYAnchor.constraint(equalTo: centerYAnchor),
//      acceptButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2)
//    ])
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
      self.acceptButton.configuration?.attributedTitle = AttributedString("acceptButton".localized.uppercased(),
                                                                      attributes: AttributeContainer([
                                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                        .foregroundColor: UIColor.white as Any
                                                                      ]))
      } else {
        self.acceptButton.setAttributedTitle(NSAttributedString(string: "acceptButton".localized.uppercased(),
                                                          attributes: [
                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
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
