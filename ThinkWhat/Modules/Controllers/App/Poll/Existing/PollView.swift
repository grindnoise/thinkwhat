//
//  PollView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Agrume
import Combine

class PollView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: (PollViewInput & UIViewController)?
  //Logic
  public weak var item: Survey? {
    didSet {
      guard !viewInput.isNil, !item.isNil else { return }
      
      setupUI()
      setTasks()
    }
  }
  
  //
  //  lazy var test: UIView = {
  //    let instance = UIView()
  //    instance.backgroundColor = .red
  //    instance.heightAnchor.constraint(equalTo: instanxce.widthAnchor, multiplier: 1/1).isActive = true
  //    instance.heightAnchor.constraint(equalToConstant: 50).isActive = true
  //    instance.layer.zPosition = 2
  //    return instance
  //  }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Publishers
  private let isVotingPublisher = PassthroughSubject<Bool, Never>()
  //Logic
  private var selectedAnswer: Answer? {
    didSet {
      guard let constraint = actionButton.getConstraint(identifier: "top") else { return }
      
      if oldValue.isNil, !selectedAnswer.isNil {
        showButton(delay: 0, flag: true)
      } else if selectedAnswer.isNil {
        showButton(delay: 0, flag: false)
      }
      if #available(iOS 15, *) {
        self.actionButton.getSubview(type: UIButton.self)?.configuration?.baseBackgroundColor = self.selectedAnswer.isNil ? .systemGray : Colors.getColor(forId: self.selectedAnswer!.order)
      } else {
        self.actionButton.getSubview(type: UIButton.self)?.backgroundColor = self.selectedAnswer.isNil ? .systemGray : Colors.getColor(forId: self.selectedAnswer!.order)
      }
    }
  }
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var collectionView: PollCollectionView = {
    func makeHelper() -> AgrumePhotoLibraryHelper {
      let saveButtonTitle = "save_image".localized
      let cancelButtonTitle = "cancel".localized
      let helper = AgrumePhotoLibraryHelper(saveButtonTitle: saveButtonTitle, cancelButtonTitle: cancelButtonTitle) { error in
        guard error == nil else {
          print("Could not save your photo")
          return
        }
        print("Photo has been saved to your library")
      }
      return helper
    }
    
    let instance = PollCollectionView(item: item!, mode: viewInput!.mode)
//    instance.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0.0)
    instance.layer.masksToBounds = false
    instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: instance.contentInset.left, bottom: item.isNil ? 100 : item!.isComplete ? 100 : 120, right: instance.contentInset.right)
    instance.imagePublisher
      .sink {[weak self] in
        guard let self = self,
              let survey = self.item,
              let controller = self.viewInput
        else { return }
        
        let images = survey.media.sorted { $0.order < $1.order }.compactMap {$0.image}
        let agrume = Agrume(images: images, startIndex: $0.order, background: .colored(.black))
        let helper = makeHelper()
        agrume.onLongPress = helper.makeSaveToLibraryLongPressGesture
        agrume.show(from: controller)
        
        guard images.count > 1 else { return }
        
        agrume.didScroll = { [weak self] index in
          guard let self = self else { return }
          
          self.collectionView.onImageScroll(index)
        }
      }
      .store(in: &subscriptions)
    instance.profileTapPublisher
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.viewInput?.openUserprofile()
      }.store(in: &subscriptions)
    
    instance.webPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.openURL($0)
      }
      .store(in: &subscriptions)
    instance.answerSelectionPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.selectedAnswer = $0
      }
      .store(in: &subscriptions)
    instance.answerDeselectionPublisher
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.selectedAnswer = nil
      }
      .store(in: &subscriptions)
    instance.votersPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.showVoters(for: $0)
      }
      .store(in: &subscriptions)
    
    //Comments
    //New comment
    instance.commentPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.postComment(body: $0, replyTo: nil, username: nil)
      }
      .store(in: &subscriptions)
    //New anon comment
    instance.anonCommentPublisher
      .sink { [weak self] in
        guard let self = self,
              let text = $0.values.first,
              let username = $0.keys.first
        else { return }
        
        self.viewInput?.postComment(body: text, replyTo: nil, username: username)
      }
      .store(in: &subscriptions)
    //Reply
    instance.replyPublisher
      .sink { [weak self] in
        guard let self = self,
        let replyTo = $0.keys.first,
        let text = $0.values.first
        else { return }
        
        self.viewInput?.postComment(body: text, replyTo: replyTo, username: nil)
      }
      .store(in: &subscriptions)
    //Anon reply
    instance.anonReplyPublisher
      .sink { [weak self] in
        guard let self = self,
              let dict = $0.values.first,
              let replyTo = $0.keys.first,
              let username = dict.keys.first,
              let text = dict.values.first
        else { return }
        
        self.viewInput?.postComment(body: text, replyTo: replyTo, username: username)
      }
      .store(in: &subscriptions)
    //Delete
    instance.deletePublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.deleteComment($0)
      }
      .store(in: &subscriptions)
    
    //Thread
    instance.threadPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.openCommentThread($0)
      }
      .store(in: &subscriptions)
    
    //Update comments stats (replies)
    instance.commentsUpdateStatsPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.updateCommentsStats($0)
      }
      .store(in: &subscriptions)
    
    
    isVotingPublisher
      .sink { instance.isVotingSubscriber.send($0) }
      .store(in: &subscriptions)
    //        //Claim
    //        instance.claimSubject.sink { [unowned self] in
    //            guard let item = $0 else { return }
    //
    //            let banner = Popup()
    //            let claimContent = ClaimPopupContent(parent: banner, surveyReference: self.item?.reference)
    //
    //            claimContent.claimPublisher
    //                .sink { [weak self] in
    //                    guard let self = self else { return }
    //
    //                    self.viewInput?.onCommentClaim(comment: item, reason: $0)
    //                }
    //                .store(in: &self.subscriptions)
    //
    //            banner.present(content: claimContent)
    //            banner.didDisappearPublisher
    //                .sink { [weak self] _ in
    //                    guard let self = self else { return }
    //
    //                    banner.removeFromSuperview()
    //                }
    //                .store(in: &self.subscriptions)
    //
    //        }.store(in: &subscriptions)
    //
    //        //Subscibe for thread disclosure
    //        instance.commentThreadSubject.sink { [weak self] in
    //            guard let self = self,
    //                  let comment = $0
    //            else { return }
    //
    //            self.viewInput?.openCommentThread(comment)
    //        }.store(in: &self.subscriptions)
    
    return instance
  }()
  private var actionButtonState: ButtonState = .Send
  
  public private(set) lazy var actionButton: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = .systemGray2
      config.attributedTitle = AttributedString((viewInput!.mode == .Preview ? "post_poll" : "vote").localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = .systemGray//item.topic.tagColor
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: (viewInput!.mode == .Preview ? "post_poll" : "vote").localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor // self.traitCollection.userInterfaceStyle == .dark ? self.item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.lightGray.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = .zero // self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = UIColor.systemBackground.withAlphaComponent(0).cgColor
    instance.colors = [clear, clear, clear]
    instance.locations = [0.0, 1, 1]
    instance.frame = frame
    publisher(for: \.bounds)
      .sink { instance.bounds = $0 }
      .store(in: &subscriptions)
    layer.addSublayer(instance)
    
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
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .systemBackground
//    setTasks()
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    let clear = UIColor.systemBackground.withAlphaComponent(0).cgColor
    let feathered = UIColor.systemBackground.withAlphaComponent(0.975).cgColor
    gradient.colors = [clear, clear, feathered]
  }
}

// MARK: - Private
private extension PollView {
  @MainActor
  func setupUI() {
//    backgroundColor = .systemBackground
    
    collectionView.place(inside: self)
//    addSubview(collectionView)
//    collectionView.translatesAutoresizingMaskIntoConstraints = false
//    collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
//    collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
//    collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
//    collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    guard !item!.isComplete else { return }
    
//    item!.reference.isCompletePublisher
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] _ in
//        guard let self = self else { return }
//
//        self.selectedAnswer = nil
//      }
//      .store(in: &subscriptions)
    
//    layer.addSublayer(gradient)
    addSubview(actionButton)
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    actionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    actionButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    actionButton.layer.zPosition = 10
    
    let constraint = actionButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)//, constant: -tabBarHeight)
    constraint.identifier = "top"
    constraint.isActive = true

//      if #available(iOS 15, *) {
//        actionButton.configuration?.baseBackgroundColor = item.topic.tagColor
//      } else {
//        actionButton.backgroundColor = item.topic.tagColor
//      }
    actionButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    
    guard viewInput!.mode == .Preview,
          let constraint = actionButton.getConstraint(identifier: "top")
    else { return }
    
//    delay(seconds: 0.5) {[weak self] in
//      guard let self = self else { return }
//
//      self.toggleFade(true)
//      setNeedsLayout()
//      //      layoutIfNeeded()
//      //      setNeedsLayout()
//      UIView.animate(
//        withDuration: 0.35,
//        delay: 0,
//        usingSpringWithDamping: 0.8,
//        initialSpringVelocity: 0.3,
//        options: [.curveEaseInOut],
//        animations: { [weak self] in
//          guard let self = self else { return }
//
//          self.actionButton.transform = .identity
//          self.actionButton.alpha = 1
//          constraint.constant = -(self.actionButton.bounds.height + tabBarHeight)
//          self.layoutIfNeeded()
//        }) { _ in }
//    }
  }
  
  func setTasks() {
    isVotingPublisher
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self,
              let answer = self.selectedAnswer
        else { return }
        
        self.viewInput?.vote(answer)
      }
      .store(in: &subscriptions)
  }
  
  @objc
  func handleTap() {
    guard actionButtonState == .Send,
          let viewInput = viewInput
    else { return }
    
    viewInput.mode == .Preview ? { viewInput.post() }() : { isVotingPublisher.send(true) }()
    actionButtonState = .Sending
    actionButton.isUserInteractionEnabled = false
    if #available(iOS 15, *) {
      actionButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString((viewInput.mode == .Preview ? "post_poll" : "vote").localized,
                                                                                                      attributes: AttributeContainer([
                                                                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                        .foregroundColor: UIColor.clear
                                                                                                      ]))
    } else {
      actionButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: (viewInput.mode == .Preview ? "post_poll" : "vote").localized,
                                                                                          attributes: [
                                                                                            .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                            .foregroundColor: UIColor.clear as Any
                                                                                          ]),
                                                                       for: .normal)
    }
    actionButton.setSpinning(on: true, color: .white, animated: true)
    
//    if #available(iOS 15, *) {
//      actionButton.configuration?.showsActivityIndicator = true
//    } else {
//      actionButton.setImage(UIImage(), for: .normal)
//      actionButton.setAttributedTitle(nil, for: .normal)
//      let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
//                                                            size: CGSize(width: actionButton.frame.height,
//                                                                         height: actionButton.frame.height)))
//      indicator.alpha = 0
//      indicator.layoutCentered(in: actionButton)
//      indicator.startAnimating()
//      indicator.color = .white
//      indicator.accessibilityIdentifier = "indicator"
//      UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
//    }
  }
  
  func showButton(delay: Double, flag: Bool) {
    // Animate gradient
    let clear = UIColor.systemBackground.withAlphaComponent(0).cgColor
    let feathered = UIColor.systemBackground.withAlphaComponent(0.975).cgColor
    
    let colorAnimation = Animations.get(property: .Colors,
                                        fromValue: gradient.colors as Any,
                                        toValue: flag ? [clear, clear, feathered] : [clear, clear, clear] as Any,
                                        duration: 0.2,
                                        delay: delay,
                                        timingFunction: flag ? CAMediaTimingFunctionName.easeOut : CAMediaTimingFunctionName.easeIn,
                                        delegate: self,
                                        isRemovedOnCompletion: false,
                                        completionBlocks: [
                                          { [weak self] in
                                            guard let self = self else { return }
                                            
                                            self.gradient.colors = flag ? [clear, clear, feathered] : [clear, clear, clear]
                                          }
                                        ])
    let locationAnimation = Animations.get(property: .Locations,
                                           fromValue: gradient.locations as Any,
                                           toValue: flag ? [0.0, 0.785, 0.81] : [0.0, 1, 1] as Any,
                                           duration: 0.2,
                                           delay: delay,
                                           timingFunction: flag ? CAMediaTimingFunctionName.easeOut : CAMediaTimingFunctionName.easeIn,
                                           delegate: self,
                                           isRemovedOnCompletion: false,
                                           completionBlocks: [
                                             { [weak self] in
                                               guard let self = self else { return }
                                               
                                               self.gradient.locations = flag ? [0.0, 0.785, 0.81] : [0.0, 1, 1]
                                               self.gradient.removeAllAnimations()
                                             }
                                           ])
    
    gradient.add(locationAnimation, forKey: nil)
    gradient.add(colorAnimation, forKey: nil)
    
    // Animate button position
    guard let constraint = actionButton.getConstraint(identifier: "top") else { return }
    
    setNeedsLayout()
    UIView.animate(
      withDuration: 0.35,
      delay: delay,//!selectedAnswer.isNil ? 0 : 0.25,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }

        self.actionButton.transform = flag ? .identity : CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.actionButton.alpha = flag ? 1 : 0
        constraint.constant = flag ? -(self.actionButton.bounds.height + tabBarHeight) : 0
        self.layoutIfNeeded()
      }) { _ in }
  }
}
  
  // MARK: - Controller Output
extension PollView: PollControllerOutput {
  func postCallback(_ result: Result<Bool, Error>) {
//    guard let constraint = actionButton.getConstraint(identifier: "top") else { return }
//
//
//    delay(seconds: 0.5) { [weak self] in
//      guard let self = self else { return }
//
//      self.toggleFade(false)
//      setNeedsLayout()
//      UIView.animate(
//        withDuration: 0.4,
//        delay: 0,
//        usingSpringWithDamping: 0.8,
//        initialSpringVelocity: 0.3,
//        options: [.curveEaseInOut]) {
//
//          self.actionButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//          self.actionButton.alpha = 0
//          constraint.constant = 0
//          self.layoutIfNeeded()
//        }
//    }
  }
  
  func presentView(_ item: Survey) {
    self.item = item
    collectionView.alpha = 0
    collectionView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.collectionView.alpha = 1
      self.collectionView.transform = .identity
    }
  }
  
  func loadCallback(_: Result<Bool, Error>) {
    
  }
  
  func voteCallback(_ result: Result<Bool, Error>) {
    actionButton.setSpinning(on: false, animated: false)
    switch result {
    case .success(_):
      showButton(delay: 0.25, flag: false)
    case .failure(_):
      if #available(iOS 15, *) {
        actionButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString((viewInput?.mode == .Preview ? "post_poll" : "vote").localized,
                                                                                                        attributes: AttributeContainer([
                                                                                                          .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                          .foregroundColor: UIColor.clear
                                                                                                        ]))
      } else {
        actionButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: (viewInput?.mode == .Preview ? "post_poll" : "vote").localized,
                                                                                            attributes: [
                                                                                              .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                              .foregroundColor: UIColor.clear as Any
                                                                                            ]),
                                                                         for: .normal)
      }
    }
  }
  
  func commentPostCallback(_: Result<Comment, Error>) {
    
  }
  
  func commentDeleteError() {
    
  }
}

extension PollView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
        completionBlock()
      }
    }
  }
}
