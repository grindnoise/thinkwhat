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
      guard let item = item else { return }
      
      collectionView.place(inside: self)
      
      guard !item.isComplete else { return }
      
      item.reference.isCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.selectedAnswer = nil
        }
        .store(in: &subscriptions)
      
      addSubview(actionButton)
      actionButton.translatesAutoresizingMaskIntoConstraints = false
      actionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      
      let constraint = actionButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)//, constant: -tabBarHeight)
      constraint.identifier = "top"
      constraint.isActive = true

      if #available(iOS 15, *) {
        actionButton.configuration?.baseBackgroundColor = item.topic.tagColor
      } else {
        actionButton.backgroundColor = item.topic.tagColor
      }
      actionButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
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
      guard oldValue != selectedAnswer,
            let constraint = actionButton.getConstraint(identifier: "top")
      else { return }
      
      setNeedsLayout()
      UIView.animate(
        withDuration: 0.35,
        delay: 0,//!selectedAnswer.isNil ? 0 : 0.25,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          self.actionButton.transform = self.selectedAnswer.isNil ? CGAffineTransform(scaleX: 0.75, y: 0.75) : .identity
          self.actionButton.alpha = self.selectedAnswer.isNil ? 0 : 1
          constraint.constant = self.selectedAnswer.isNil ? 0 : -(self.actionButton.bounds.height + tabBarHeight)
          self.layoutIfNeeded()
        }) { _ in }
    }
  }
  //UI
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
    
    let instance = PollCollectionView(item: item!)
    instance.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: deviceType == .iPhoneSE ? 0 : 60, right: 0.0)
    instance.layer.masksToBounds = false
    instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: instance.contentInset.left, bottom: 100, right: instance.contentInset.right)
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
  private lazy var actionButton: UIButton = {
    let instance = UIButton()
    instance.alpha = 0
    instance.addTarget(self, action: #selector(self.vote), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      let attrString = AttributedString("vote".localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.attributedTitle = attrString
      config.baseBackgroundColor = .systemGray2//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
      config.image = UIImage(systemName: "hand.point.left.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      config.imagePlacement = .trailing
      config.imagePadding = padding
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large

      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: "vote".localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ])
      instance.titleEdgeInsets.left = 20
      instance.titleEdgeInsets.right = 20
      instance.setImage(UIImage(systemName: "hand.point.left.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
      instance.imageView?.tintColor = .white
      instance.imageEdgeInsets.left = 8
      //            instance.imageEdgeInsets.right = 8
      instance.setAttributedTitle(attrString, for: .normal)
      instance.semanticContentAttribute = .forceRightToLeft
      instance.backgroundColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
    instance.translatesAutoresizingMaskIntoConstraints = false
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: self.actionButtonState.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!))
      constraint.identifier = "width"
      constraint.isActive = true
      
      instance.publisher(for: \.bounds)
        .sink { [weak self] rect in
          guard let self = self else { return }
          
          instance.cornerRadius = rect.height/3.25
          
          guard let constraint = instance.getConstraint(identifier: "width") else { return }
//          self.setNeedsLayout()
          constraint.constant = self.actionButtonState.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (instance .imageView?.bounds.width ?? 0)
//          self.layoutIfNeeded()
        }
        .store(in: &subscriptions)
    }
    
//    let shadowView = UIView()
//    shadowView.clipsToBounds = false
//    shadowView.backgroundColor = .clear
//    shadowView.accessibilityIdentifier = "shadow"
//    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
//    shadowView.layer.shadowRadius = 16
//    shadowView.layer.shadowOffset = .zero
//    shadowView.layer.zPosition = 1
//    shadowView.publisher(for: \.bounds)
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] in
//        guard let self = self else { return }
//
//        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0,
//                                                   cornerRadius: instance.cornerRadius).cgPath
//      }
//      .store(in: &subscriptions)
//    shadowView.place(inside: instance)
//    instance.layer.zPosition = 2
    
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
    
    setTasks()
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private
private extension PollView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
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
  func vote() {
    guard actionButtonState == .Send else { return }
    isVotingPublisher.send(true)
    actionButtonState = .Sending
    actionButton.isUserInteractionEnabled = false
    
    if #available(iOS 15, *) {
      actionButton.configuration?.showsActivityIndicator = true
    } else {
      actionButton.setImage(UIImage(), for: .normal)
      actionButton.setAttributedTitle(nil, for: .normal)
      let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                            size: CGSize(width: actionButton.frame.height,
                                                                         height: actionButton.frame.height)))
      indicator.alpha = 0
      indicator.layoutCentered(in: actionButton)
      indicator.startAnimating()
      indicator.color = .white
      indicator.accessibilityIdentifier = "indicator"
      UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
    }
  }
}
  
  // MARK: - Controller Output
  extension PollView: PollControllerOutput {
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
  
  func onLoadCallback(_: Result<Bool, Error>) {
    
  }
  
  func onVoteCallback(_: Result<Bool, Error>) {
    
  }
  
  func commentPostCallback(_: Result<Comment, Error>) {
    
  }
  
  func commentDeleteError() {
    
  }
}
