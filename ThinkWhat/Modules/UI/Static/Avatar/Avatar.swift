//
//  Avatar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class Avatar: UIView {
  
  enum Mode {
    case Default, Editing, Choice, Selection
  }
  
//  struct Constants {
//    static let animationDuration = 0.4
//  }
  //    @Published private var image: UIImage?
  
//  override var debugDescription: String { "Avatar for: \(userprofile!.name)" }
  
  // MARK: - Public properties
  public var mode: Mode = .Default {
    didSet {
      guard oldValue != mode else { return }
      
      if mode == .Selection {
        //                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        //                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) { [unowned self] in
        //                    self.button.alpha = 1
        //                    self.button.transform = .identity
        //                }
      } else if mode == .Default, oldValue == .Selection {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, animations: { [unowned self] in
          self.button.alpha = 0
          self.button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { _ in
          self.button.transform = .identity
        }
      } else if mode == .Editing {
        button.menu = prepareMenu()
        button.alpha = 1
        button.setImage(UIImage(systemName: "camera.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.5,
                                                                               weight: .semibold)),
                        for: .normal)
        button.imageView?.contentMode = .center
      }
    }
  }
  public weak var userprofile: Userprofile? {
    didSet {
      guard let userprofile = userprofile else { return }
      
      guard userprofile != Userprofile.anonymous else {
        imageView.image = UIImage(named: "anon")
        
        return
      }
      
      setImage(for: userprofile)
      //            userprofile.image.publisher
      //                .receive(on: DispatchQueue.main)
      //                .map { $0 }
      ////                .assign(to: &$image)
      //                .sink { [weak self] in
      //                    guard let self = self else { return }
      //
      //                    print("userpofile", self.userprofile!.id)
      //                    self.setNeedsLayout()
      //                    self.imageView.image = $0
      //                    self.layoutIfNeeded()
      //                }
      //                .store(in: &subscriptions)
      
      setTasks()
    }
  }
  public var isSelected: Bool = false {
    didSet {
      button.setImage(UIImage(systemName: isSelected ? "camera.fill" : "",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.5,
                                                                             weight: .semibold)),
                      for: .normal)
    }
  }
  public var isShadowed: Bool {
    didSet {
      layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    }
  }
  public var isBordered: Bool
  public var darkBorderColor: UIColor = .clear {
    didSet {
      guard let coloredBg = background.getSubview(type: UIView.self, identifier: "coloredBg") else { return }
      
      coloredBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkBorderColor : lightBorderColor
    }
  }
  public var lightBorderColor: UIColor {
    didSet {
//      shimmer.backgroundColor = lightBorderColor
      
      guard let coloredBg = background.getSubview(type: UIView.self, identifier: "coloredBg") else { return }
      
      coloredBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkBorderColor : lightBorderColor
    }
  }
  public var shadowColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5) {
    didSet {
      layer.shadowColor = shadowColor.cgColor
    }
  }
  public var color: UIColor = Constants.UI.Colors.System.Red.rawValue {
    didSet {
      button.tintColor = color
    }
  }
  public lazy var buttonBgLightColor: UIColor = .systemBackground{
    didSet {
      guard traitCollection.userInterfaceStyle != .dark else { return }
      button.backgroundColor = buttonBgLightColor
    }
  }
  public lazy var buttonBgDarkColor: UIColor = .systemBackground{
    didSet {
      guard traitCollection.userInterfaceStyle == .dark else { return }
      button.backgroundColor = buttonBgDarkColor
    }
  }
  public lazy var background: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "bg"
    instance.clipsToBounds = true
    instance.backgroundColor = .systemBackground
    
    if isBordered {
      let coloredBg = UIView()
      coloredBg.accessibilityIdentifier = "coloredBg"
      coloredBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkBorderColor : lightBorderColor
      coloredBg.place(inside: instance)
//      shimmer.place(inside: coloredBg)
      imageView.placeInCenter(of: coloredBg, heightMultiplier: 0.85)
      shimmer.place(inside: imageView)
    } else {
      shimmer.place(inside: instance)
      imageView.place(inside: instance)
    }
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  public lazy var shimmer: Shimmer = {
    let instance = Shimmer()
    instance.accessibilityIdentifier = "shimmer"
    instance.clipsToBounds = true
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  public lazy var imageView: UIImageView = {
    let instance = UIImageView()
    instance.contentMode = .scaleAspectFill
//    instance.tintColor = .systemGray
//    instance.alpha = 0
    instance.accessibilityIdentifier = "imageView"
    instance.layer.masksToBounds = true
    instance.backgroundColor = .clear//.systemGray2
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//    instance.publisher(for: \.image)
//      .receive(on: DispatchQueue.main)
//      .filter { !$0.isNil}
//      .sink { [weak self] _ in
//        guard let self = self else { return }
//
//        DispatchQueue.main.async {
//          //                    instance.alpha = 0
//          UIView.animate(withDuration: 0.25, delay: 0, animations: { [weak self] in
//            guard let self = self else { return }
//
//            instance.alpha = 1
//          }) { _ in
//            self.shimmer.stopShimmering()
//          }
//        }
//      }
//      .store(in: &subscriptions)
    
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  @Published public private(set) var image: UIImage? {
    didSet {
      guard let image = image else { return }
      
      self.shimmer.stopShimmering()
      self.shimmer.alpha = 0
      self.shimmer.removeFromSuperview()
      
      guard !self.ciFilterName.isEmpty else {
        imageView.image = image
//        shimmer.backgroundColor = .clear
        
        return
      }
      
      guard let userprofile = userprofile,
            let filteredImage = userprofile.filteredImage
      else {
        Task { [weak self] in
          guard let self = self else { return }
          
          self.filteredImage = await image.setFilterAsync(filter: ciFilterName)
        }
        
        return
      }
      self.filteredImage = filteredImage
    }
  }
  @Published public private(set) var filteredImage: UIImage? {
    didSet {
      guard let image = filteredImage,
            let userprofile = userprofile,
            userprofile.filteredImage.isNil
      else { return }
      
      userprofile.filteredImage = image
    }
  }
  public var choiceColor: UIColor?
  @MainActor public private(set) var isUploading = false
  //Publishers
  public let galleryPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let cameraPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let previewPublisher = CurrentValueSubject<UIImage?, Never>(nil)
  public let tapPublisher = PassthroughSubject<Userprofile, Never>()
  public let selectionPublisher = CurrentValueSubject<[Userprofile: Bool]?, Never>(nil)
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
//  private lazy var shadowView: UIView = {
//    let instance = UIView()
//    instance.layer.masksToBounds = false
//    instance.backgroundColor = .clear
//    instance.accessibilityIdentifier = "shadowView"
//    instance.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
//    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
//    instance.layer.shadowOffset = .zero
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//    instance.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink {
//        instance.layer.shadowPath = UIBezierPath(ovalIn: $0).cgPath
//        instance.layer.shadowRadius = $0.height/8
//      }
//      .store(in: &subscriptions)
//
//    background.addEquallyTo(to: instance)
//    return instance
//  }()
  private lazy var button: UIButton = {
    let instance = UIButton()
    instance.alpha = mode == .Default ? 0 : 1
    instance.menu = prepareMenu()
    instance.showsMenuAsPrimaryAction = true
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? buttonBgDarkColor : buttonBgLightColor
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Constants.UI.Colors.main
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    //        instance.isContextMenuInteractionEnabled = true
    //        instance.addInteraction(UIContextMenuInteraction(delegate: self))
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self else { return }
        
        instance.cornerRadius = rect.height/2
        instance.imageView?.contentMode = .center
        guard self.mode == .Choice,
              let image = self.choiceImage,
              let choiceColor = self.choiceColor
        else {
          var systemImage = ""
          
          switch self.mode {
          case .Selection:
            systemImage = self.isSelected ? "checkmark" : ""
          case .Editing:
            systemImage = "camera.fill"
            //      case .Choice:
            //        systemImage = "circlebadge.fill"
          default:
            systemImage = ""
          }
          instance.setImage(UIImage(systemName: systemImage,
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5,
                                                                                   weight: .semibold)),
                            for: .normal)
          
          return
        }
        
        instance.setImage(image.withConfiguration(UIImage.SymbolConfiguration(pointSize: rect.height*0.75,
                                                                                 weight: .semibold)),
                          for: .normal)
        instance.tintColor = self.choiceColor
        
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var choiceImage: UIImage?
  private var ciFilterName: String
  // Progress circle
  private let showsProgress: Bool
  private lazy var progressLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.lineCap = .round
    instance.shadowOffset = .zero
    instance.masksToBounds = false
    instance.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.strokeEnd = 0
    
    return instance
  }()
  private lazy var progressBackgroundLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
//    instance.strokeStart = 0
//    instance.strokeEnd  = 1
//    instance.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.white.blended(withFraction: 0.1, of: UIColor.lightGray).cgColor
    instance.strokeColor = traitCollection.userInterfaceStyle == .dark ? progressBgDarkColor.cgColor : progressBgLightColor.cgColor
    
    return instance
  }()
  private var progressColor: UIColor {
    didSet {
      progressLayer.strokeColor = progressColor.cgColor
      progressLayer.shadowColor = progressColor.withAlphaComponent(0.5).cgColor
    }
  }
  private var progressBgLightColor: UIColor
  private var progressBgDarkColor: UIColor
  private var progressValue: Double
  private let progressLineWidthMultiplier: CGFloat 
  private let progressBgLineWidthMultiplier: CGFloat
  
  
  
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
  init(userprofile: Userprofile? = nil,
       size: CGSize = .zero,
       isShadowed: Bool = false,
       isBordered: Bool = false,
       lightBorderColor: UIColor = .clear,
       darkBorderColor: UIColor = .clear,
       mode: Mode = .Default,
       filter: String = "",
       showsProgress: Bool = false,
       progressColor: UIColor = .systemGray,
       progressValue: Double = .zero,
       progressBgLightColor: UIColor = .systemBackground,
       progressBgDarkColor: UIColor = .systemBackground,
       progressLineWidthMultiplier: CGFloat = 0.09,
       progressBgLineWidthMultiplier: CGFloat = 0.15) {
    self.mode = mode
    self.isShadowed = isShadowed
    self.isBordered = isBordered
    self.lightBorderColor = lightBorderColor
    self.darkBorderColor = darkBorderColor
    self.userprofile = userprofile
    self.ciFilterName = filter
    self.showsProgress = showsProgress
    self.progressColor = progressColor
    self.progressValue = progressValue
    self.progressBgLightColor = progressBgLightColor
    self.progressBgDarkColor = progressBgDarkColor
    self.progressLineWidthMultiplier = progressLineWidthMultiplier
    self.progressBgLineWidthMultiplier = progressBgLineWidthMultiplier
    
    let frame = CGRect(origin: .zero, size: size)
    
    super.init(frame: frame)
    
    self.frame = frame
    setTasks()
    setupUI()
    
    guard userprofile == Userprofile.anonymous else {return }
    
//    imageView.image = UIImage(named: "anon")!
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: - Public methods
  public func clearImage() {
    //        let largeConfig = UIImage.SymbolConfiguration(pointSize: imageView.bounds.height*0.65, weight: .regular, scale: .medium)
    //        imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
    //        imageView.tintColor = .white
    //        imageView.contentMode = .center
    imageView.image = nil
  }

  public func setUserprofileDefaultImage() {
    imageView.tintColor = .systemGray
    imageView.backgroundColor = .secondarySystemBackground
    imageView.image = UIImage(named: "person")
//    imageView.publisher(for: \.bounds)
//      .sink { [weak self] in
//        guard let self = self else { return }
//
//        self.imageView.backgroundColor = .secondarySystemBackground
//        self.imageView.image = UIImage(systemName: "person.fill",
//                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: $0.height * 0.65))
//      }
//      .store(in: &subscriptions)
  }
  
  public func setSelected(_ isSelected: Bool) {
    guard mode == .Selection else { return }
    
    button.isSelected = isSelected
  }
  
  public func imageUploadStarted(_ image: UIImage) {
    guard mode == .Editing else { return }
    
    isUploading = true
    
    let fade = UIView()
    fade.backgroundColor = .black.withAlphaComponent(0.6)
    fade.accessibilityIdentifier = "fade"
    fade.alpha = 0
    fade.addEquallyTo(to: imageView)
    
    let spinner = UIActivityIndicatorView()
    spinner.accessibilityIdentifier = "spinner"
    spinner.style = .large
    spinner.alpha = 0
    spinner.color = .white
    spinner.startAnimating()
    spinner.addEquallyTo(to: imageView)
    
    Animations.changeImageCrossDissolve(imageView: imageView, image: image)
    
    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) { [weak self] in
      guard let self = self else { return }
      
      self.button.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
      self.button.alpha = 0
      fade.alpha = 1
      spinner.alpha = 1
    }
  }
  
  public func imageUploadFinished(_ result: Result<UIImage, Error>) {
    isUploading = false
    
    switch result {
    case .success(let image):
      Animations.changeImageCrossDissolve(imageView: imageView, image: image)
      let banner = NewBanner(contentView: TextBannerContent(image: image,
                                                            text: "image_uploaded",
                                                            tintColor: self.color,
                                                            fontName: Fonts.Regular,
                                                            textStyle: .headline,
                                                            textAlignment: .natural,
                                                            cornerRadius: 0.05),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    case .failure(let error):
      let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                            text: error.localizedDescription,
                                                            tintColor: .systemRed,
                                                            fontName: Fonts.Regular,
                                                            textStyle: .subheadline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    }

    guard let fade = imageView.getSubview(type: UIView.self, identifier: "fade"),
          let spinner = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "spinner")
    else { return }
    
    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: { [weak self] in
      guard let self = self else { return }
      
      self.button.transform = .identity
      self.button.alpha = 1
      fade.alpha = 0
      spinner.alpha = 0
    }) { _ in
      fade.removeFromSuperview()
      spinner.removeFromSuperview()
    }
  }
  
  public func setChoiceBadge(image: UIImage, color: UIColor) {
    choiceColor = color
    choiceImage = image
    mode = .Choice
    
    button.setImage(image.withConfiguration(UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.75,
                                                                             weight: .semibold)),
                      for: .normal)
    button.tintColor = color
    button.alpha = 1
//    button.setImage(image.withConfiguration(UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.6,
//                                                                           weight: .semibold)),
//                    for: .normal)
    //    button.imageView?.contentMode = .center
  }
  
  
  /// Sets photo filter by using CICategoryColorEffect
  /// - Parameters:
  ///   - name: CICategoryColorEffect string. If empty - sets back default image
  ///   - duration: time interval to animate.
  ///
  public func toggleFilter(on: Bool, duration: TimeInterval = .zero) {
    guard let image = on ? self.filteredImage : self.image else { return }
    
    if duration != .zero {
      Animations.changeImageCrossDissolve(imageView: imageView,
                                          image: image,
                                          duration: duration)
    } else {
      imageView.image = image
    }
  }
   
  /// Sets circular progress path
  /// - Parameters:
  ///   - value: percent
  ///   - duration: animation duration
  public func setProgress(value: Double, duration: Double = .zero) {
    guard !value.isZero,
          value != progressValue
    else { return }
    
    let strokeEnd = value/100
    
    if !duration.isZero {
      progressLayer.add(Animations.get(property: .LineWidth,
                                       fromValue: progressLayer.lineWidth,
                                       toValue: progressLayer.lineWidth*1.25,
                                       duration: duration/2,
                                       autoreverses: true,
                                       timingFunction: .linear,
                                       isRemovedOnCompletion: true), forKey: nil)
      
//      progressLayer.add(Animations.get(property: .StrokeColor,
//                                       fromValue: progressLayer.strokeColor as Any,
//                                       toValue: progressColor.withLuminosity(0.65).cgColor,
//                                       duration: Constants.animationDuration/2,
//                                       autoreverses: true,
//                                       timingFunction: .linear,
//                                       isRemovedOnCompletion: true), forKey: nil)
      
      progressLayer.add(Animations.get(property: .StrokeEnd,
                                       fromValue: progressLayer.strokeEnd,
                                       toValue: strokeEnd,
                                       duration: duration*1.1,
                                       timingFunction: .easeInEaseOut,
                                       delegate: self,
                                       isRemovedOnCompletion: false,
                                       completionBlocks: { [weak self] in
        guard let self = self else { return }
        
        self.progressLayer.strokeEnd = strokeEnd
        self.progressLayer.removeAllAnimations()
        self.progressValue = strokeEnd
      }), forKey: nil)
    } else {
      progressLayer.strokeEnd = strokeEnd
    }
    progressValue = strokeEnd
  }
  
  /// Sets progress path color
  /// - Parameter color: path color
  public func setProgressColor(_ color: UIColor) {
    progressColor = color
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    
    button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? buttonBgDarkColor : buttonBgLightColor
    
    if showsProgress {
      progressBackgroundLayer.strokeColor = traitCollection.userInterfaceStyle == .dark ? progressBgDarkColor.cgColor : progressBgLightColor.cgColor
//      progressBackgroundLayer.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.white.blended(withFraction: 0.1, of: UIColor.lightGray).cgColor
    }
    
    guard let coloredBg = background.getSubview(type: UIView.self, identifier: "coloredBg") else { return }
    
    coloredBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkBorderColor : lightBorderColor
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let constraintY = button.getConstraint(identifier: "constraintY"),
          let constraintX = button.getConstraint(identifier: "constraintX")
    else { return }
    
    let point = pointOnCircle(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.height/2, angleInDegrees: 135)
    constraintY.constant = point.y
    constraintX.constant = point.x
  }
}

// MARK: - Private
private extension Avatar {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    
    layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    layer.shadowColor = shadowColor.cgColor//UIColor.lightGray.withAlphaComponent(0.5).cgColor
    layer.shadowOffset = .zero
//    layer.shadowRadius = 8
    publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { [unowned self] in
        if self.showsProgress {
          self.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.75).cgColor
          let lineWidth = $0.width*self.progressBgLineWidthMultiplier
          let newRect = CGRect(origin: .zero, size: CGSize(width: $0.width + lineWidth,
                                                           height: $0.height + lineWidth))
          self.layer.shadowPath = UIBezierPath(ovalIn: newRect.offsetBy(dx: -lineWidth/2, dy: -lineWidth/2)).cgPath
        } else {
          self.layer.shadowPath = UIBezierPath(ovalIn: $0).cgPath
        }
        self.layer.shadowRadius = min($0.height/8, 8) //self.showsProgress ? $0.height/4 : min($0.height/8, 8)
      }
      .store(in: &subscriptions)
    
    background.place(inside: self)
    
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),
    ])
    
    let constraintX = button.centerXAnchor.constraint(equalTo: leadingAnchor)
    constraintX.isActive = true
    constraintX.identifier = "constraintX"
    
    let constraintY = button.centerYAnchor.constraint(equalTo: topAnchor)
    constraintY.isActive = true
    constraintY.identifier = "constraintY"
    
    // Setup progress layer
    guard showsProgress else { return }
    
    layer.addSublayer(progressBackgroundLayer)
    layer.addSublayer(progressLayer)
    if !progressValue.isZero {
      progressLayer.strokeEnd = progressValue/100
    }
    publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { [weak self] rect in
        guard let self = self else { return }
        
        let lineWidthBg = rect.width * self.progressBgLineWidthMultiplier
        let newRect = CGRect(origin: .zero, size: CGSize(width: rect.width + lineWidthBg,
                                                         height: rect.height + lineWidthBg))
        
        let path = UIBezierPath(arcCenter: CGPoint(x: newRect.midX - lineWidthBg/2, y: newRect.midY - lineWidthBg/2),
                                radius: newRect.width/2,
                                startAngle: -CGFloat.pi / 2,
                                endAngle: CGFloat.pi * 2,
                                clockwise: true).cgPath
        //UIBezierPath(ovalIn: newRect.offsetBy(dx: -lineWidthBg/4, dy: -lineWidthBg/4)).cgPath
        self.progressBackgroundLayer.lineWidth = lineWidthBg
        self.progressBackgroundLayer.path = path // UIBezierPath(ovalIn: newRect.offsetBy(dx: -lineWidthBg/4, dy: -lineWidthBg/4)).cgPath
        
        let lineWidth = rect.width * self.progressLineWidthMultiplier
        let newRect2 = CGRect(origin: .zero, size: CGSize(width: newRect.width + (lineWidthBg - lineWidth),
                                                          height: newRect.height + (lineWidthBg - lineWidth)))
        self.progressLayer.lineWidth = lineWidth
        self.progressLayer.path = UIBezierPath(arcCenter: CGPoint(x: newRect2.midX - (lineWidthBg + (lineWidthBg - lineWidth))/2, y: newRect2.midY - (lineWidthBg + (lineWidthBg - lineWidth))/2),
                                               radius: newRect2.width/2,
                                               startAngle: -.pi / 2,
                                               endAngle: -.pi / 2 + .pi * 2,
                                               clockwise: true).cgPath
        
        self.setProgressColor(self.progressColor)
        self.progressLayer.shadowRadius = newRect2.width*0.025
//        self.progressLayer.path = UIBezierPath(ovalIn: newRect.offsetBy(dx: -lineWidthBg/4, dy: -lineWidthBg/4)).cgPath
//        self.progressLayer.path = UIBezierPath(
//          arcCenter: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0),
//          radius: rect.width - lineWidth,
//          startAngle: CGFloat(-Double.pi / 2),
//          endAngle: CGFloat(-Double.pi / 2) + (2 * .pi),
//          clockwise: true
//      ).cgPath
      }
      .store(in: &subscriptions)
    
  }
  
  func setTasks() {
    guard let userprofile = userprofile else { return }
    
    setImage(for: userprofile)
    
    userprofile.imagePublisher
      .receive(on: DispatchQueue.main)
      .filter { [unowned self] _ in self.isUploading }
      .sink(receiveCompletion: { [weak self] in
        guard let self = self else { return }

        guard self.isUploading else { return }
        
        if case .failure(let error) = $0 {
          self.imageUploadFinished(.failure(error))
        }
      }, receiveValue: { [weak self] in
        guard let self = self else { return }
        
        guard self.isUploading else { self.image = $0; return }
        
        self.imageUploadFinished(.success($0))
      })
      .store(in: &subscriptions)
    
    userprofile.imagePublisher
      .filter { [unowned self] _ in !self.isUploading }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] in
        guard let self = self else { return }
        
        if case .failure(let error) = $0 {
          self.setUserprofileDefaultImage()
#if DEBUG
          print(error)
#endif
        }
      }, receiveValue: { [weak self] in
        guard let self = self else { return }
        
        self.image = $0
      })
      .store(in: &subscriptions)
    
    $filteredImage
//      .receive(on: DispatchQueue.main)
      .filter { !$0.isNil }
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.imageView.image = $0
      }
      .store(in: &subscriptions)
  }
  
  func setImage(for userprofile: Userprofile) {
    guard userprofile != Userprofile.anonymous else {
      imageView.image = UIImage(named: "anon")
      
      return
    }
    
    guard let image = userprofile.image else {
      if !userprofile.imageURL.isNil {
        shimmer.startShimmering()
//        userprofile.downloadImage()
        Task {
          do {
            try await userprofile.downloadImageAsync()
          } catch {
            await MainActor.run { [weak self] in
              guard let self = self else { return }
                
              self.setUserprofileDefaultImage()
            }
          }
        }
        return
      }
      
      return
    }
    
//    imageView.image = image
    self.image = image
  }
  
  func pointOnCircle(center: CGPoint, radius: CGFloat, angleInDegrees: CGFloat) -> CGPoint {
    func deg2rad(_ number: Double) -> CGFloat {
      return number * .pi / 180
    }
    
    let radian = deg2rad(angleInDegrees)
    
    return CGPoint(x: center.x + radius * sin(radian),
                   y: center.y + radius * cos(radian))
  }
  
  func prepareMenu() -> UIMenu {
    var actions = [UIAction]()
    
    switch mode {
    case .Editing:
      let camera: UIAction = .init(title: "camera".localized.capitalized,
                                   image: UIImage(systemName: "camera.fill"),
                                   identifier: nil,
                                   discoverabilityTitle: nil,
                                   attributes: .init(),
                                   state: .off,
                                   handler: { [weak self] _ in
        guard let self = self else { return }
        
        self.cameraPublisher.send(true)
      })
      
      let photos: UIAction = .init(title: "photo_album".localized.capitalized, image: UIImage(systemName: "photo"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
        guard let self = self else { return }
        
        self.galleryPublisher.send(true)
      })
      
      actions = [photos, camera]
    case .Choice:
      print("")
    default:
      print("")
    }
    
    return UIMenu(title: "change_avatar".localized, image: nil, identifier: nil, options: .init(), children: actions)
  }
  
  @objc
  func handleTap() {
    guard let userprofile = userprofile else { return }
    
    switch mode {
    case .Editing:
      guard !isUploading, let image = imageView.image else { return }
      
      previewPublisher.send(image)
    case .Selection:
      isSelected = !isSelected
      button.setImage(UIImage(systemName: isSelected ? "checkmark" : "",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.6,weight: .heavy)),
                      for: .normal)
      
      switch isSelected {
      case true:
        button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        button.alpha = 0
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) { [unowned self] in
          self.button.alpha = 1
          self.button.transform = .identity
        }
      case false:
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) { [unowned self] in
          self.button.alpha = 0
          self.button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
      }
      
      
      selectionPublisher.send([userprofile: isSelected])
    default:
      tapPublisher.send(userprofile)
    }
  }
  
  func setFilter(filterName: String, for image: UIImage) {
    Task { [weak self] in
      guard let self = self else { return }
      
      self.filteredImage = image.setFilter(filter: filterName)
    }
  }
  
  /// Animates progress
  /// - Parameter duration: animation duration
  func animateProgressLayer(duration: TimeInterval) {
    progressLayer.add(Animations.get(property: .StrokeEnd,
                                     fromValue: 0,
                                     toValue: 1,
                                     duration: duration,
                                     timingFunction: .easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false,
                                     completionBlocks: { [weak self] in
      guard let self = self else { return }
      
      self.progressLayer.strokeEnd = 1
      self.progressLayer.removeAllAnimations()
    }), forKey: nil)
  }
}


extension Avatar: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}


//extension Avatar: UIContextMenuInteractionDelegate {
//
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//
//        return UIContextMenuConfiguration(
//            identifier: nil,
//            previewProvider: makeRatePreview) { [weak self] _ in
//                guard let self = self else { return nil }
//
//                return self.prepareMenu()
//            }
//    }
//
//    func makeRatePreview() -> UIViewController {
//      let viewController = UIViewController()
//
//      // 1
//      let imageView = UIImageView(image: UIImage(named: "rating_star"))
//      viewController.view = imageView
//
//      // 2
//      imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//      imageView.translatesAutoresizingMaskIntoConstraints = false
//
//      // 3
//      viewController.preferredContentSize = imageView.frame.size
//
//      return viewController
//    }
//}

