//
//  CommentCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentCell: UICollectionViewListCell {
  
  enum Mode {
    case Plain, Root, Thread
  }
  
  
  
  // MARK: - Public properties
  public var item: Comment! {
    didSet {
      guard let item = item else { return }
      
      setupUI()

      item.repliesPublisher
        .receive(on: DispatchQueue.main)
//        .filter { $0 > 0 }
        .sink { [weak self] in
          guard let self = self,
                self.mode == .Plain
          else { return }
          
          if item.isOwn {
//            self.repliesView.alpha = $0 > 0 ? 1 : 0
            self.replyButton.removeFromSuperview()
          }
          
//          self.repliesButton.alpha = $0 > 0 ? 1 : 0
          let attrString = NSMutableAttributedString(string: " \(String(describing: $0)) ", attributes: [
            .font: UIFont.scaledFont(fontName: !item.replies.isZero ? Fonts.Rubik.SemiBold : Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
            .foregroundColor: $0.isZero ? UIColor.secondaryLabel : UIColor.systemBlue
          ])
          self.repliesButton.setAttributedTitle(attrString, for: .normal)
          self.repliesButton.tintColor = $0.isZero ? UIColor.secondaryLabel : UIColor.systemBlue
        }
        .store(in: &subscriptions)
      item.isDeletedPublisher
        .sink { [weak self] _ in
          guard let self = self//,
//                let item = self.item
          else { return }
          
//          if item.isOwn {
//            let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "trash.fill")!,
//                                                                  text: "comment_deleted",
//                                                                  tintColor: .systemRed),
//                                   contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                                   isModal: false,
//                                   useContentViewHeight: true,
//                                   shouldDismissAfter: 1)
//            banner.didDisappearPublisher
//              .sink { _ in banner.removeFromSuperview() }
//              .store(in: &self.subscriptions)
//          }
          self.shouldAnimateConstraints = true
          UIView.transition(with: self.textView, duration: 0.2, options: .transitionCrossDissolve) {
            self.textView.text = "comment_is_deleted".localized
            self.textView.font = UIFont.scaledFont(fontName: Fonts.Rubik.Italic, forTextStyle: .footnote)
            self.textView.textColor = .secondaryLabel
          } completion: { _ in self.shouldAnimateConstraints = false }
        }
        .store(in: &subscriptions)
      item.isBannedPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.shouldAnimateConstraints = true
          UIView.transition(with: self.textView, duration: 0.2, options: .transitionCrossDissolve) {
            self.textView.text = "comment_is_banned".localized
            self.textView.textColor = .secondaryLabel
            self.repliesButton.tintColor = UIColor.secondaryLabel
          } completion: { _ in self.shouldAnimateConstraints = false }
        }
        .store(in: &subscriptions)
    }
  }
  public var mode: CommentCell.Mode = .Plain
  ///**Publishers**
  public var replyPublisher = PassthroughSubject<Comment, Never>()
  public var claimPublisher = PassthroughSubject<Comment, Never>()
  public var deletePublisher = PassthroughSubject<Comment, Never>()
  public var threadPublisher = PassthroughSubject<Comment, Never>()
  public let boundsPublisher = PassthroughSubject<Void, Never>()

  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private var shouldAnimateConstraints = false
  private let padding: CGFloat = 8
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.isUserInteractionEnabled = false
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote)
    instance.isEditable = false
    instance.isSelectable = false
    instance.backgroundColor = .clear
    instance.textContainerInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 1,
                                               right: 0)
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reply)))
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 10)// mode == .Root ? estimatedHeight : 10)
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize, options: .new)
//      .filter { [unowned self] _ in self.mode != .Root }
      .sink { [unowned self] size in
        guard let constraint = instance.getConstraint(identifier: "height"),
              constraint.constant != size.height
        else { return }
        
        if self.shouldAnimateConstraints {
          UIView.animate(withDuration: 0.3) {
            self.setNeedsLayout()
            constraint.constant = abs(size.height)// * 1.5
            self.layoutIfNeeded()
            let space = constraint.constant - size.height
            let inset = max(0, space/2)
            instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
            self.boundsPublisher.send()
          }
        } else {
          self.setNeedsLayout()
          constraint.constant = abs(size.height)
          self.layoutIfNeeded()
          let space = constraint.constant - size.height
          let inset = max(0, space/2)
          instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
          self.boundsPublisher.send()
          
          return
        }
        
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var avatar: Avatar = {
    let instance = Avatar(isShadowed: false)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//    instance.layer.masksToBounds = false
    
    return instance
  }()
  private lazy var userView: UIView = {
    let instance = UIView()
//    instance.layer.masksToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "userView"
    
    //        instance.addSubview(firstnameLabel)
    //        instance.addSubview(lastnameLabel)
    instance.addSubview(avatar)
    
    //        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
    //        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
    avatar.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      avatar.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
      avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),//, constant: 8),
      avatar.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
//      avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.9),
    ])
    return instance
  }()
  //Date & claim
  private lazy var dateLabel: UITextView = {
    let instance = UITextView()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption2)
    instance.textAlignment = .left
    instance.text = "1234"
    instance.isUserInteractionEnabled = false
    instance.isSelectable = false
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    instance.backgroundColor = .clear
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: abs(instance.contentSize.height/1.5))//instance.contentSize.height)//"text".height(withConstrainedWidth: 100, font: instance.font!))
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize, options: .new)
      .sink { [unowned self] size in
        guard let constraint = self.dateLabel.getConstraint(identifier: "height") else { return }
        
        self.setNeedsLayout()
        constraint.constant = abs(size.height)// * 1.5
        self.layoutIfNeeded()
        let space = constraint.constant - size.height//self.textView.contentSize.height
        let inset = max(0, space/2)
        self.dateLabel.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var menuButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    //        instance.addTarget(self, action: #selector(self.claim), for: .touchUpInside)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    //        instance.contentMode = .bottom
    instance.alpha = item.isOwn && item.isDeleted ? 0 : 1
    
    return instance
  }()
  private lazy var supplementaryStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [dateLabel, menuButton])
    instance.axis = .horizontal
//    instance.clipsToBounds = false
    instance.spacing = 4
    instance.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      instance.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
    ])
    
    return instance
  }()
  private lazy var repliesButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "bubble.right.fill", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.scaledFont(fontName: Fonts.Rubik.Light, forTextStyle: .footnote)!, scale: .small)), for: .normal)
    instance.imageView?.contentMode = .left
    instance.contentEdgeInsets.left = padding/2
    //        instance.semanticContentAttribute = .forceRightToLeft
    instance.tintColor = item.replies.isZero ? UIColor.secondaryLabel : UIColor.systemBlue//item.survey?.topic.tagColor ?? .systemBlue//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
    instance.addTarget(self, action: #selector(self.replies), for: .touchUpInside)
//    instance.imageEdgeInsets.right = padding
    //        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    
    //        let constraint = instance.widthAnchor.constraint(equalToConstant: "text".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)!))
    //        constraint.identifier = "width"
    //        constraint.isActive = true
    
    return instance
  }()
  private lazy var repliesView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.isUserInteractionEnabled = true
    //        instance.addSubview(replyButton)
    //        instance.addSubview(repliesButton)
    //        instance.translatesAutoresizingMaskIntoConstraints = false
    
    
//    let innerView = UIView.opaque()
    let stack = UIStackView()//arrangedSubviews: [UIView.horizontalSpacer(padding/2)])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.spacing = padding
    switch mode {
    case .Thread:
      stack.addArrangedSubview(replyButton)
    default:
      stack.addArrangedSubview(repliesButton)
      stack.addArrangedSubview(replyButton)
//      replyButton.heightAnchor.constraint(equalTo: repliesButton.heightAnchor).isActive = true
    }
    instance.addSubview(stack)
//    if mode != .Child {
//      stack.addArrangedSubview(replyLabel)
//      innerView.addSubview(repliesButton)
//      repliesButton.translatesAutoresizingMaskIntoConstraints = false
//    }
//    innerView.addSubview(replyButton)
//
//    instance.addSubview(innerView)
    
//    innerView.translatesAutoresizingMaskIntoConstraints = false
//    replyButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
//      innerView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
      stack.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
//      innerView.heightAnchor.constraint(equalTo: repliesButton.heightAnchor),
//      repliesButton.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
//      replyButton.leadingAnchor.constraint(equalTo: repliesButton.trailingAnchor, constant: 16),
//      replyButton.heightAnchor.constraint(equalTo: repliesButton.heightAnchor),
      
      
      
      //            replyButton.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
      //            repliesButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 8),
      ////            instance.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
      //            repliesButton.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
      //            instance.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
      //            instance.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),
      //            instance.bottomAnchor.constraint(equalTo: innerView.bottomAnchor),
      //            instance.topAnchor.constraint(equalTo: innerView.topAnchor, constant: 8),
    ])
    
    //        instance.heightAnchor.constraint(equalTo: supplementaryStack.heightAnchor).isActive = true
    
    return instance
  }()
  private lazy var replyButton: UIButton = {
    let instance = UIButton()
//    instance.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.scaledFont(fontName: Fonts.Rubik.Light, forTextStyle: .footnote)!, scale: .medium)), for: .normal)
    instance.tintColor = UIColor.systemGray//item.survey?.topic.tagColor ?? .systemBlue //traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
    instance.addTarget(self, action: #selector(self.reply), for: .touchUpInside)
    let attrString = NSMutableAttributedString(string: " " + "reply".localized.uppercased(), attributes: [
      NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
      NSAttributedString.Key.foregroundColor: UIColor.systemBlue//item.survey?.topic.tagColor ?? UIColor.systemBlue
    ])
    instance.setAttributedTitle(attrString, for: .normal)
//    instance.contentVerticalAlignment = .fill
//    instance.contentHorizontalAlignment = .fill
//    instance.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let constraint = instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)!))
    constraint.identifier = "height"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [userView, verticalStack])
    instance.axis = .horizontal
//    instance.layer.masksToBounds = false
    instance.spacing = 0
    
    userView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.125).isActive = true
    
    //        NSLayoutConstraint.activate([
    //            userView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: mode == .Root ? 0.125 : 0.2),
    //        ])
    
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [supplementaryStack, textView])//, repliesView])
    instance.axis = .vertical
    instance.alignment = .center
//    instance.layer.masksToBounds = false
    instance.spacing = padding/2
    
    supplementaryStack.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      supplementaryStack.widthAnchor.constraint(equalTo: instance.widthAnchor),
      textView.widthAnchor.constraint(equalTo: instance.widthAnchor),
      //            repliesView.widthAnchor.constraint(equalTo: instance.widthAnchor),
    ])
    
    return instance
  }()
  private lazy var replyLabel: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.isUserInteractionEnabled = true
    instance.translatesAutoresizingMaskIntoConstraints = false
    
    let label = UILabel()
    label.accessibilityIdentifier = "label"
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reply)))
    label.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .headline)
    label.text = "add_reply".localized
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    label.backgroundColor = .clear
    
    let constraint = label.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 1000, font: label.font))
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: instance.topAnchor, constant: padding/2),
      label.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: padding),
      label.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -padding),
      instance.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: padding/2),
    ])
    
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
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
//    setTasks()
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func hideDisclosure() {
    repliesButton.alpha = 0
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    dateLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    menuButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    setHeader()
    if mode == .Root {
      backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : Colors.lightTheme
    }
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    textView.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular,
                                      forTextStyle: .footnote)
    guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
    setNeedsLayout()
    constraint.constant = abs(textView.contentSize.height)
    layoutIfNeeded()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    item = nil
    replyPublisher = PassthroughSubject<Comment, Never>()
    claimPublisher = PassthroughSubject<Comment, Never>()
    deletePublisher = PassthroughSubject<Comment, Never>()
    threadPublisher = PassthroughSubject<Comment, Never>()

    avatar.clearImage()
    //        supplementaryStack.removeArrangedSubview(menuButton)
    //        menuButton.removeFromSuperview()
    verticalStack.removeArrangedSubview(repliesView)
    repliesView.removeFromSuperview()
    //        tasks.forEach { $0?.cancel() }
    //        setTasks()
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -100).isActive = true
    separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 100).isActive = true
  }
}

// MARK: - Private
private extension CommentCell {
  @MainActor
  func setupUI() {
    func prepareMenu() -> UIMenu {
      var actions: [UIAction]!
      if item.isOwn {
        let deleteAction : UIAction = .init(title: "delete".localized, image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [weak self] action in
          guard let self = self,
                let instance = self.item
          else { return }
          
          self.deletePublisher.send(instance)
        })
        actions = [deleteAction]
      } else {
        let replyAction : UIAction = .init(title: "reply".localized, image: UIImage(systemName: "arrowshape.turn.up.left.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
          guard let self = self,
                let instance = self.item
          else { return }
          
          self.replyPublisher.send(instance)
        })
        replyAction.accessibilityIdentifier = "reply"
        
        
        let claimAction : UIAction = .init(title: "make_claim".localized, image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [weak self] action in
          guard let self = self,
                let instance = self.item
          else { return }
          
          self.claimPublisher.send(instance)
        })
        actions = [claimAction]
        if mode != .Root {
          actions.append(replyAction)
        }
      }
      
      return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
    }
    
    backgroundColor = .clear
    clipsToBounds = true
    
    contentView.addSubview(horizontalStack)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: mode == .Plain ? 0 : padding),
      horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: mode == .Plain ? 0 : -padding),
    ])
    
    let constraint = horizontalStack.getConstraint(identifier: "leadingAnchor") ?? {
      let instance = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mode == .Plain ? 0 : padding)
      instance.identifier = "leadingAnchor"
      
      return instance
    }()
    constraint.isActive = true
    
    menuButton.menu = prepareMenu()
    menuButton.showsMenuAsPrimaryAction = true
    
    switch mode {
    case .Plain:
      verticalStack.addArrangedSubview(repliesView)
      repliesView.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true
      
      if let constraint = repliesButton.getConstraint(identifier: "bottomAnchor") {
        repliesButton.removeConstraint(constraint)
      }
      let bottomAnchor = repliesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
      bottomAnchor.identifier = "bottomAnchor"
      bottomAnchor.priority = .defaultHigh
      bottomAnchor.isActive = true
    case .Thread:
      hideDisclosure()
      
      verticalStack.addArrangedSubview(repliesView)
      repliesView.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true
      
      if let constraint = repliesView.getConstraint(identifier: "bottomAnchor") {
        repliesView.removeConstraint(constraint)
      }
      
      let bottomAnchor = repliesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
      bottomAnchor.identifier = "bottomAnchor"
      bottomAnchor.priority = .defaultHigh
      bottomAnchor.isActive = true
    case .Root:
//      backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : Colors.lightTheme
      guard !item.isOwn else { return }
      
      let opaque = UIView.opaque()
      replyLabel.place(inside: opaque, insets: .init(top: padding, left: 0, bottom: 0, right: 0))
      
      verticalStack.removeArrangedSubview(repliesView)
      repliesView.removeFromSuperview()
      verticalStack.addArrangedSubview(opaque)
      opaque.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true
      
      if let constraint = replyLabel.getConstraint(identifier: "bottomAnchor") {
        replyLabel.removeConstraint(constraint)
      }
      
      let bottomAnchor = replyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
      bottomAnchor.identifier = "bottomAnchor"
      bottomAnchor.priority = .defaultHigh
      bottomAnchor.isActive = true
    }
    
    if item.isOwn {
      replyButton.removeFromSuperview()
    }
    
    setHeader()
    setBody()
    
    replyButton.alpha = item.isDeleted ? 0 : item.isOwn ? 0 : 1
    
    if let userprofile = item.userprofile {
      avatar.userprofile = userprofile.isCurrent ? Userprofiles.shared.current : userprofile
      if let usersChoice = avatar.userprofile!.answers[item.surveyId],
         let answer = Answers.shared[usersChoice],
         let image = UIImage(systemName: "\(answer.order+1).circle.fill") {
        avatar.setChoiceBadge(image: image, color: Colors.getColor(forId: answer.order))
      }
    } else {
      avatar.userprofile = Userprofile.anonymous
    }
    repliesButton.tintColor = item.replies.isZero ? UIColor.secondaryLabel : UIColor.systemBlue
    let attrString = NSMutableAttributedString(string: " \(item.replies)",// " + "replies_total".localized.uppercased(),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: !item.replies.isZero ? Fonts.Rubik.SemiBold : Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
                                                .foregroundColor: item.replies.isZero ? UIColor.secondaryLabel : UIColor.systemBlue//item.survey?.topic.tagColor ?? UIColor.systemBlue
                                               ])
    repliesButton.setAttributedTitle(attrString, for: .normal)
    
    if mode == .Thread {
      repliesButton.alpha = 0
    }
    
    setNeedsLayout()
    layoutIfNeeded()
  }
    
  func setHeader() {
    let attrString = NSMutableAttributedString()
    if !item.isAnonymous, let userprofile = item.userprofile {
      let instance = NSAttributedString(string: userprofile.username + " ",
                                        attributes: [
                                          .font : UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .caption2) as Any,
                                          .foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray
                                        ])
      attrString.append(instance)
//      if !userprofile.firstNameSingleWord.isEmpty {
//        let instance = NSAttributedString(string: userprofile.firstNameSingleWord + " ",
//                                          attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .caption2) as Any,
//                                                       NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//        attrString.append(instance)
//        if !userprofile.lastNameSingleWord.isEmpty {
//          let lastname = NSAttributedString(string: userprofile.lastNameSingleWord + " ",
//                                            attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .caption2) as Any,
//                                                         NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//          attrString.append(lastname)
//        }
//      } else {
//        let instance = NSAttributedString(string: userprofile.lastNameSingleWord + " ",
//                                          attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .caption2) as Any,
//                                                       NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//        attrString.append(instance)
//      }
    } else {
      let instance = NSAttributedString(string: item.anonUsername + " ",
                                        attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .caption2) as Any,
                                                     NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
      attrString.append(instance)
    }
    let date = NSAttributedString(string: item.createdAt.timeAgoDisplay(),
                                  attributes: [
                                    .font : UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption2) as Any,
                                    .foregroundColor : UIColor.secondaryLabel
                                  ])
    attrString.append(date)
    dateLabel.attributedText = attrString
  }
  
  func setBody() {
    if mode == .Thread {
      let attrString = NSMutableAttributedString()
      if let survey = item.survey, survey.isAnonymous, let reply = item.replyTo {
        let reply = NSAttributedString(string: "@" + reply.anonUsername, attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.systemGray
        ])
        attrString.append(reply)
      } else if let replyItem = item.replyTo, /*!replyItem.isParentNode,*/ let userprofile = replyItem.userprofile {
        attrString.append(NSAttributedString(string: "@" + userprofile.username, attributes: [
          .font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
          .foregroundColor: UIColor.systemGray
        ]))
      }
      
      if item.isBanned || item.isDeleted {
        textView.attributedText = NSAttributedString(string: item.isBanned ? "comment_is_banned".localized : "comment_is_deleted".localized,
                                                     attributes: [
                                                      NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.Italic, forTextStyle: .footnote) as Any,
                                                      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
                                                     ])
      } else {
        let body = NSAttributedString(string: " " + item.body, attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.label
        ])
        
        attrString.append(body)
        textView.attributedText = attrString
      }
    } else {
      if item.isBanned || item.isDeleted {
        textView.attributedText = NSAttributedString(string: item.isBanned ? "comment_is_banned".localized : "comment_is_deleted".localized,
                                                     attributes: [
                                                      NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.Italic, forTextStyle: .footnote) as Any,
                                                      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
                                                     ])
      } else {
        textView.text = item.body
      }
    }
  }
  
  @objc
  func reply() {
    guard let item = item else { return }
    
    replyPublisher.send(item)
  }
  
  @objc
  func claim() {
    guard let item = item else { return }
    
    claimPublisher.send(item)
  }
  
  @objc
  func replies() {
    guard let item = item,
          item.replies != 0
    else { return }
    
    threadPublisher.send(item)
  }
}
