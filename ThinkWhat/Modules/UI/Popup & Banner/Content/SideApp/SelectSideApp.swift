//
//  SideApp.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

final class SelectSideApp: UIView {

  // MARK: - Public properties
  public var inAppPublisher = PassthroughSubject<Bool, Never>()
  public var sideAppPublisher = PassthroughSubject<Bool, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private let app: Enums.ThirdPartyApp
  //UI
  private let padding: CGFloat = 8
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
        imageContainer,
        verticalStack,
        UIView.opaque()
    ])
    instance.axis = .horizontal
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var imageContainer: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    let logo = app.logo()
    logo.heightAnchor.constraint(equalTo: logo.widthAnchor, multiplier: 1/1).isActive = true
    logo.placeInCenter(of: instance, heightMultiplier: 0.75)
    
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let nestedStack1 = UIStackView(arrangedSubviews: [
      openEmbeddedButton,
      UIView.opaque()
    ])
    let nestedStack2 = UIStackView(arrangedSubviews: [
      openAppButton,
      UIView.opaque()
    ])
    let instance = UIStackView(arrangedSubviews: [
      nestedStack1,
      nestedStack2,
      nestedStack
    ])
    instance.spacing = 4
    instance.axis = .vertical
    
    return instance
  }()
  private lazy var openEmbeddedButton: UIButton = {
    let instance = UIButton()
    instance.backgroundColor = .clear
    instance.addTarget(self, action: #selector(self.handleEvent(sender:)), for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: "open_url_embedded".localized, attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body) as Any,
      .foregroundColor: UIColor.systemBlue
    ]),
                                for: .normal)
    instance.titleLabel?.textAlignment = .left
    let constraint = instance.heightAnchor.constraint(equalToConstant: "1".height(withConstrainedWidth: 100,
                                                                                  font: UIFont.scaledFont(fontName: Fonts.Semibold,
                                                                                                          forTextStyle: .body)!))
    constraint.isActive = true
    saveSwitch.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { constraint.constant = $0.height }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var openAppButton: UIButton = {
    let instance = UIButton()
    instance.backgroundColor = .clear
    instance.addTarget(self, action: #selector(self.handleEvent(sender:)), for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: "open_url_in_app".localized + app.rawValue,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body) as Any,
                                                    .foregroundColor: UIColor.systemBlue
                                                   ]),
                                for: .normal)
    instance.titleLabel?.textAlignment = .left
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: "1".height(withConstrainedWidth: 100,
                                                                                  font: UIFont.scaledFont(fontName: Fonts.Semibold,
                                                                                                          forTextStyle: .body)!))
    constraint.isActive = true
    saveSwitch.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { constraint.constant = $0.height }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var nestedStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      saveLabel,
      saveSwitch,
      UIView.opaque()
    ])
    instance.axis = .horizontal
    instance.spacing = padding
    instance.alignment = .leading
    
//    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
//    constraint.isActive = true
//
//    saveSwitch.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink { constraint.constant = $0.height }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var saveLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline)
    instance.text = "save_setting".localized
    instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100,
                                                                          font: instance.font)).isActive = true
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: "1".height(withConstrainedWidth: 100, font: instance.font))
    constraint.isActive = true
    saveSwitch.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { constraint.constant = $0.height }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var saveSwitch: UISwitch = {
    let instance = UISwitch()
    instance.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
    
    return instance
  }()
  
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
  init(app: Enums.ThirdPartyApp) {
    self.app = app
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    saveSwitch.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
  }
}

private extension SelectSideApp {
  @MainActor
  func setupUI() {
    horizontalStack.place(inside: self)
  }
  
  @objc
  func handleEvent(sender: UIButton) {
    if sender == openAppButton {
      sideAppPublisher.send(true)
      sideAppPublisher.send(completion: .finished)
      
      guard saveSwitch.isOn else { return }
      
      switch app {
      case .Youtube:
        UserDefaults.App.youtubePlay = .App
      case .TikTok:
        UserDefaults.App.tiktokPlay = .App
      default:
#if DEBUG
      print("")
#endif
      }
    } else {
      inAppPublisher.send(true)
      inAppPublisher.send(completion: .finished)
      
      guard saveSwitch.isOn else { return }
      
      switch app {
      case .Youtube:
        UserDefaults.App.youtubePlay = .Embedded
      case .TikTok:
        UserDefaults.App.tiktokPlay = .Embedded
      default:
#if DEBUG
      print("")
#endif
      }
    }
  }
}
//8 495 135 15 51



////
////  SideApp.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 17.08.2021.
////  Copyright © 2021 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//import Combine
//
//final class SelectSideApp: UIView {
//    var app: ThirdPartyApp = .Null {
//        didSet {
//            if oldValue != app {
//                if icon != nil {
//                    icon.subviews.forEach({ $0.removeFromSuperview() })
//                    let _icon = app.getIcon()
//                    _icon.isOpaque = false
//                    _icon.addEquallyTo(to: icon)
//                }
//                if openButton != nil {
//                    openButton.setTitle("Открыть в приложении \(app.rawValue)", for: .normal)
//                }
//            }
//        }
//    }
//    var foldable = false
//    var minHeigth: CGFloat {
//        return topView.frame.height
//    }
//    var maxHeigth: CGFloat {
//        return topView.frame.height
//    }
//
//    weak var delegate: CallbackObservable?
//    deinit {
//        print("Warning banner deinit")
//    }
//
//    @IBOutlet var contentView: UIView!
//    @IBOutlet weak var topView: UIView!
//    @IBOutlet weak var icon: UIView!
//
//    @IBOutlet weak var playButton: UIButton! {
//        didSet {
//            playButton.setTitle("play_youtube".localized, for: .normal)
//        }
//    }
//    @IBAction func playEmbedded(_ sender: Any) {
//        if defaultSwitch.isOn {
//            switch app {
//            case .TikTok:
//                UserDefaults.App.tiktokPlay = .Embedded
//            case .Youtube:
//                UserDefaults.App.youtubePlay = .Embedded
//            case .Null:
//                print("")
//            }
//        }
//        self.delegate?.callbackReceived(SideAppPreference.Embedded)
////        if localhost {
////        UserDefaults.App.youtubePlay = nil
////        }
//    }
//    @IBOutlet weak var openButton: UIButton! {
//        didSet {
//            var title = ""
//            if app == .Youtube {
//                title = "open_youtube".localized
//            } else if app == .TikTok {
//                title = "open_tiktok".localized
//            }
//            openButton.setTitle(title, for: .normal)
//        }
//    }
//    @IBAction func openYoutubeApp(_ sender: Any) {
//        if defaultSwitch.isOn {
//            switch app {
//            case .TikTok:
//                UserDefaults.App.tiktokPlay = .App
//            case .Youtube:
//                UserDefaults.App.youtubePlay = .App
//            case .Null:
//                print("")
//            }
//        }
//        self.delegate?.callbackReceived(SideAppPreference.App)
////        if localhost {
////        UserDefaults.App.youtubePlay = nil
////        }
//    }
//
//    @IBAction func onChange(_ sender: UISwitch) {
//        print(sender.isOn)
//    }
//    @IBOutlet weak var defaultSwitch: UISwitch! {
//        didSet {
//            defaultSwitch.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
//        }
//    }
//    @IBOutlet weak var label: UILabel! {
//        didSet {
//            label.text = "remember".localized
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        self.setupUI()
//    }
//
//    init(app: ThirdPartyApp) {
//        super.init(frame: .zero)
//
//        self.app = app
//        self.setupUI()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        self.setupUI()
//    }
//
//    init(width: CGFloat) {
//        let _frame = CGRect(origin: .zero, size: CGSize(width: width, height: width))///frameRatio))
//        super.init(frame: _frame)
//
//        self.setupUI()
//    }
//
//    private func setupUI() {
//        Bundle.main.loadNibNamed("SideApp", owner: self, options: nil)
//        guard let content = contentView else {
//            return
//        }
//        content.frame = self.bounds
//        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        self.addSubview(content)
//        self.backgroundColor = .clear
//        guard !icon.isNil else { return }
//        switch app {
//        case .TikTok:
//            let v = TikTokLogo(frame: icon.frame)
//            v.isOpaque = false
//            v.addEquallyTo(to: icon)
//        case .Youtube:
//            let v = YoutubeLogo(frame: icon.frame)
//            v.isOpaque = false
//            v.addEquallyTo(to: icon)
//        case .Null:
//            print("")
//        }
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//      super.traitCollectionDidChange(previousTraitCollection)
//
//      defaultSwitch.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
//    }
//}
