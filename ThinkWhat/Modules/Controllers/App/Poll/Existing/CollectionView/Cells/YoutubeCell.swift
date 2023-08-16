//
//  YoutubeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import Combine

class YoutubeCell: UICollectionViewCell {
  
  // MARK: - Overriden properties
  override var isSelected: Bool { didSet { updateAppearance() } }
  
  // MARK: - Public Properties
  public var item: Survey! {
    didSet {
      guard !item.isNil, let url = item.url, let id = url.absoluteString.youtubeID else { return }
      
      playerView.load(withVideoId: id)
      setupUI()
    }
  }
  public weak var callbackDelegate: CallbackObservable?
  public var mode: PollCollectionView.ViewMode = .Default
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "video.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .scaleAspectFit
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Colors.cellHeader
    instance.text = "media".localized.uppercased()
    instance.font = Fonts.cellHeader

    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    heightConstraint.identifier = "height"
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true

    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }

        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView()
    instance.image = UIImage(systemName: "chevron.down")
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    
    return instance
  }()
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [headerImage,
                                                  headerLabel,
                                                  disclosureIndicator,
                                                  UIView.opaque()])
    instance.alignment = .center
    let constraint = instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font))
    constraint.identifier = "height"
    constraint.isActive = true
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let verticalStack = UIStackView()//arrangedSubviews: [horizontalStack, imageContainer])
    if mode == .Default {
      verticalStack.addArrangedSubview(horizontalStack)
    }
    verticalStack.addArrangedSubview(shadowView)
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    
    return verticalStack
  }()
  private var closedConstraint: NSLayoutConstraint!
  private var openConstraint: NSLayoutConstraint!
  private lazy var shadowView: UIView = {
    let instance = UIView.opaque()
    instance.layer.masksToBounds = false
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.35).cgColor
    instance.layer.shadowOffset = .zero
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowRadius = padding*0.65///2
    instance.publisher(for: \.bounds)
      .sink { instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.025).cgPath }
      .store(in: &subscriptions)
    playerView.place(inside: instance)
    
    return instance
  }()
  private lazy var playerView: WKYTPlayerView = {
    let instance = WKYTPlayerView()
    instance.webView?.isOpaque = false
    instance.webView?.backgroundColor = .clear
    instance.webView?.scrollView.isOpaque = false
    instance.webView?.scrollView.backgroundColor = .clear
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    instance.delegate = self
    
    let shimmer = Shimmer()
    shimmer.layer.zPosition = 100
    shimmer.place(inside: instance)
    shimmer.startShimmering()
    
    return instance
  }()
  private let padding: CGFloat = 8
  private var tempAppPreference: Enums.SideAppPreference?
  private var sideAppPreference: Enums.SideAppPreference? {
    if UserDefaults.App.youtubePlay == nil {
      return nil
    } else {
      return UserDefaults.App.youtubePlay
    }
  }
  private var isYoutubeInstalled: Bool {
    let appName = "youtube"
    let appScheme = "\(appName)://app"
    let appUrl = URL(string: appScheme)
    return UIApplication.shared.canOpenURL(appUrl! as URL)
  }
  private var color = UIColor.systemGray
  private lazy var opaqueView: UIView = {
    let instance = UIView()
    instance.layer.zPosition = 100
    instance.backgroundColor = .white.withAlphaComponent(0.05)
    instance.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(self.handleTap(sender:))))
    
    return instance
  }()
  var isPresentingBanner = false
  
  
  
  // MARK: - Destructor
  deinit {
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : !isSelected ? 1 : 0
//    verticalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
//      $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
//    }
//    //        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
////    playerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.2)
//    //        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//    //        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//    //        if let imageView = icon.get(all: UIImageView.self).first {
//    //            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//    //        }
//
//    //Set dynamic font size
//    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//
//    disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                             forTextStyle: .caption1)
//    guard let constraint = horizontalStack.getConstraint(identifier: "height"),
//          let constraint_2 = disclosureLabel.getConstraint(identifier: "width")
//    else { return }
//    setNeedsLayout()
//    constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
//    constraint_2.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
//    layoutIfNeeded()
  }
}

// MARK: - Private
private extension YoutubeCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    contentView.addSubview(verticalStack)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    verticalStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding*2),
      verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
    ])

    color = item.topic.tagColor
//    setNeedsLayout()
//    layoutIfNeeded()
    
//    guard mode == .Default else {
//      playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
//
//      return
//    }

    closedConstraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    closedConstraint.priority = .defaultLow

    openConstraint = verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    openConstraint.priority = .defaultLow

    updateAppearance(animated: false)
  }
  
  /// Updates the views to reflect changes in selection
  func updateAppearance(animated: Bool = true) {
    closedConstraint.isActive = isSelected
    openConstraint.isActive = !isSelected
    
    guard animated else {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
      shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : !isSelected ? 1 : 0
      
      return
    }
    UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
      self.shadowView.alpha = !self.isSelected ? 1 : 0
    }
  }
  
  func openYotubeApp() {
    guard let url = item.url, let id = url.absoluteString.youtubeID else { return }
    let appScheme = "youtube://watch?v=\(id)"
    if let appUrl = URL(string: appScheme) {
      UIApplication.shared.open(appUrl)
    }
  }
  
  @objc
  func handleTap(sender: UIView) {
    if sender == opaqueView {
//      let contentView = SelectSideApp(app: .Youtube)
//      let banner = NewBanner(contentView: contentView,
//                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                             isModal: true,
//                             useContentViewHeight: true)
//      banner.didDisappearPublisher
//        .sink { _ in banner.removeFromSuperview() }
//        .store(in: &self.subscriptions)
//
//      contentView.inAppPublisher
//        .sink { [weak self] _ in
//          guard let self = self else { return }
//
//          print("inAppPublisher")
//          banner.dismiss()
//        }
//        .store(in: &self.subscriptions)
//
//      contentView.sideAppPublisher
//        .sink { [weak self] _ in
//          guard let self = self else { return }
//
//          print("sideAppPublisher")
//          banner.dismiss()
//        }
//        .store(in: &self.subscriptions)
//      opaqueView.removeFromSuperview()
    }
  }
}

//extension YoutubeCell: CallbackObservable {
//  func callbackReceived(_ sender: Any) {
//    if let preference = sender as? SideAppPreference {
//      if preference == .App {
//        tempAppPreference = .App
//        openYotubeApp()
//        playerView.stopVideo()
//      } else {
//        playerView.playVideo()
//        tempAppPreference = .Embedded
//      }
//    }
//  }
//}

extension YoutubeCell: WKYTPlayerViewDelegate {
  func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
    guard let shimmer = playerView.getSubview(type: Shimmer.self) else { return }
    
    shimmer.stopShimmering(animated: true)
    shimmer.removeFromSuperview()
    playerView.webView?.scrollView.isOpaque = false
    playerView.webView?.scrollView.backgroundColor = .clear
    
//    playerView.webView?.scrollView.subviews.forEach { view in
//      view.isOpaque = false
//      view.backgroundColor = .white
//      view.subviews.forEach { v in
//        v.isOpaque = false
//        v.backgroundColor = .white
//        v.subviews.forEach {
//          $0.isOpaque = false
//          $0.backgroundColor = .white
//        }
//      }
//    }
//    UIView.animate(withDuration: 0.2, animations: {
//      self.loadingIndicator.alpha = 0
//    }) {
//      _ in
//      self.loadingIndicator.removeAllAnimations()
//      self.loadingIndicator.removeFromSuperview()
//    }
    
//    guard isYoutubeInstalled else { return }
//
//    opaqueView.place(inside: playerView)
//    guard isYoutubeInstalled else { return }
//
//    opaqueView.isUserInteractionEnabled = true
  }
  
  func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
    guard state == .buffering else { return }
    
    guard !isPresentingBanner, !sideAppPreference.isNil || !tempAppPreference.isNil else {
      playerView.stopVideo()
      
      isPresentingBanner = true
      let contentView = SelectSideApp(app: .Youtube)
      let banner = NewBanner(contentView: contentView,
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: true,
                             useContentViewHeight: true)
      banner.didDisappearPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.isPresentingBanner = false
          banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
      
      contentView.inAppPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.tempAppPreference = .Embedded
          delayAsync(delay: 0.5) {
            self.playerView.playVideo()
          }
          banner.dismiss()
        }
        .store(in: &self.subscriptions)
      
      contentView.sideAppPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.tempAppPreference = .App
          self.openYotubeApp()
          banner.dismiss()
        }
        .store(in: &self.subscriptions)
//      opaqueView.removeFromSuperview()
      
      return
    }
    
    if !sideAppPreference.isNil {
      switch sideAppPreference {
      case .App:
        guard isYoutubeInstalled else { playerView.playVideo(); return }
        openYotubeApp()
        playerView.stopVideo()
      default:
        playerView.playVideo()
      }
    } else if !tempAppPreference.isNil {
      switch tempAppPreference {
      case .App:
        guard isYoutubeInstalled else { playerView.playVideo(); return }
        openYotubeApp()
        playerView.stopVideo()
      default:
        playerView.playVideo()
      }
    }
  }
}

//extension YoutubeCell: BannerObservable {
//    func onBannerWillAppear(_ sender: Any) {}
//
//    func onBannerWillDisappear(_ sender: Any) {}
//
//    func onBannerDidAppear(_ sender: Any) {}
//
//    func onBannerDidDisappear(_ sender: Any) {
//        if let banner = sender as? Banner {
//            banner.removeFromSuperview()
//        } else if let popup = sender as? Popup {
//            popup.removeFromSuperview()
//        }
//    }
//}
