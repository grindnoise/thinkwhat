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
    case Plain, Root, Child
  }
  
  // MARK: - Public properties
  public var item: Comment! {
    didSet {
      guard let item = item else { return }
      
      updateUI()
      
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
          
//          self.disclosureButton.alpha = $0 > 0 ? 1 : 0
          let attrString = NSMutableAttributedString(string: " \(String(describing: $0)) " + "replies_total".localized.uppercased(), attributes: [
            NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue
          ])
          self.disclosureButton.setAttributedTitle(attrString, for: .normal)
        }
        .store(in: &subscriptions)
      item.isDeletedPublisher
        .sink { [weak self] _ in
          guard let self = self,
                let item = self.item
          else { return }
          
          if item.isOwn {
            let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "trash.fill")!,
                                                                  text: "comment_deleted",
                                                                  tintColor: .systemRed),
                                   contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                   isModal: false,
                                   useContentViewHeight: true,
                                   shouldDismissAfter: 1)
            banner.didDisappearPublisher
              .sink { _ in banner.removeFromSuperview() }
              .store(in: &self.subscriptions)
          }
          
          UIView.transition(with: self.textView, duration: 0.2, options: .transitionCrossDissolve) {
            self.textView.text = "comment_is_deleted".localized
            self.textView.textColor = .secondaryLabel
          } completion: { _ in }
        }
        .store(in: &subscriptions)
      item.isBannedPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          UIView.transition(with: self.textView, duration: 0.2, options: .transitionCrossDissolve) {
            self.textView.text = "comment_is_banned".localized
            self.textView.textColor = .secondaryLabel
          } completion: { _ in }
        }
        .store(in: &subscriptions)
    }
  }
  public var mode: CommentCell.Mode = .Plain {
    didSet {
      guard oldValue != mode else { return }
      
      updateUI()
//      setBody()
      
//      if mode == .Tree {
//        disclosureButton.alpha = 0
//      }
//
//      guard let constraint = horizontalStack.getConstraint(identifier: "leadingAnchor") else { return }
//
//      setNeedsLayout()
//      constraint.constant = mode == .Tree ? padding*2 : 0//avatar.bounds.width/2 : 0
//      layoutIfNeeded()
    }
  }
  //Publishers
  public var replyPublisher = PassthroughSubject<Comment, Never>()
  public var claimPublisher = PassthroughSubject<Comment, Never>()
  public var deletePublisher = PassthroughSubject<Comment, Never>()
  public var threadPublisher = PassthroughSubject<Comment, Never>()
  
  //  public var commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
  //  public var claimSubject = CurrentValueSubject<Comment?, Never>(nil)
  //  public var deleteSubject = CurrentValueSubject<Comment?, Never>(nil)
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  // UI
  private let padding: CGFloat = 8
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.isUserInteractionEnabled = false
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
    instance.isEditable = false
    instance.isSelectable = false
    instance.textContainerInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 1,
                                               right: 0)
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reply)))
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize, options: .new)
      .sink { [unowned self] size in
        guard let constraint = instance.getConstraint(identifier: "height") else { return }
        
        self.setNeedsLayout()
        constraint.constant = size.height// * 1.5
        self.layoutIfNeeded()
        let space = constraint.constant - size.height
        let inset = max(0, space/2)
        instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var avatar: Avatar = {
    let instance = Avatar(isShadowed: true)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    return instance
  }()
  private lazy var userView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
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
      avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
      avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.9),
    ])
    return instance
  }()
  //Date & claim
  private lazy var dateLabel: UITextView = {
    let instance = UITextView()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    instance.textAlignment = .left
    instance.text = "1234"
    instance.isUserInteractionEnabled = false
    instance.isSelectable = false
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: instance.contentSize.height/1.5)//instance.contentSize.height)//"text".height(withConstrainedWidth: 100, font: instance.font!))
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize, options: .new)
      .sink { [unowned self] size in
        guard let constraint = self.dateLabel.getConstraint(identifier: "height") else { return }
        
        self.setNeedsLayout()
        constraint.constant = size.height// * 1.5
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
    //        instance.alpha = 0
    
    return instance
  }()
  private lazy var supplementaryStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [dateLabel, menuButton])
    instance.axis = .horizontal
    instance.clipsToBounds = false
    instance.spacing = 4
    instance.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      instance.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
    ])
    
    return instance
  }()
  private lazy var disclosureButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "bubble.right.fill", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.scaledFont(fontName: Fonts.OpenSans.Light.rawValue, forTextStyle: .footnote)!, scale: .medium)), for: .normal)
    //        instance.semanticContentAttribute = .forceRightToLeft
    instance.tintColor = .systemBlue//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
    instance.addTarget(self, action: #selector(self.replies), for: .touchUpInside)
//    instance.imageEdgeInsets.right = padding
    //        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    
    //        let constraint = instance.widthAnchor.constraint(equalToConstant: "text".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)!))
    //        constraint.identifier = "width"
    //        constraint.isActive = true
    
    return instance
  }()
  private lazy var repliesView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.isUserInteractionEnabled = true
    //        instance.addSubview(replyButton)
    //        instance.addSubview(disclosureButton)
    //        instance.translatesAutoresizingMaskIntoConstraints = false
    
    
    let innerView = UIView()
    innerView.backgroundColor = .clear
    innerView.addSubview(disclosureButton)
    innerView.addSubview(replyButton)
    
    instance.addSubview(innerView)
    
    innerView.translatesAutoresizingMaskIntoConstraints = false
    replyButton.translatesAutoresizingMaskIntoConstraints = false
    disclosureButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      innerView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
      innerView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
      innerView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
      innerView.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
      innerView.heightAnchor.constraint(equalTo: disclosureButton.heightAnchor),
      replyButton.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
      disclosureButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 16),
      replyButton.heightAnchor.constraint(equalTo: disclosureButton.heightAnchor),
      
      
      
      //            replyButton.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
      //            disclosureButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 8),
      ////            instance.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
      //            disclosureButton.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
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
    instance.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.scaledFont(fontName: Fonts.OpenSans.Light.rawValue, forTextStyle: .footnote)!, scale: .medium)), for: .normal)
    instance.tintColor = .systemBlue //traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
    instance.addTarget(self, action: #selector(self.reply), for: .touchUpInside)
    let attrString = NSMutableAttributedString(string: " " + "reply".localized.uppercased(), attributes: [
      NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
      NSAttributedString.Key.foregroundColor: UIColor.systemBlue
    ])
    instance.setAttributedTitle(attrString, for: .normal)
    //        instance.contentVerticalAlignment = .fill
    //        instance.contentHorizontalAlignment = .fill
    //        instance.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let constraint = instance.heightAnchor.constraint(equalToConstant: "text".height(withConstrainedWidth: 1000, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)!))
    constraint.identifier = "height"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [userView, verticalStack])
    instance.axis = .horizontal
    instance.clipsToBounds = false
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
    instance.clipsToBounds = false
    instance.spacing = 0
    
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
    label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .callout)
    label.text = "add_reply".localized
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    label.backgroundColor = .clear
    
    let constraint = label.heightAnchor.constraint(equalToConstant: "add_reply".height(withConstrainedWidth: 1000, font: label.font))
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
      .sink { instance.cornerRadius = $0.size.height/2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  // Constraints
  //    private var closedConstraint: NSLayoutConstraint!
  //    private var openConstraint: NSLayoutConstraint!
  
  
  
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
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func hideDisclosure() {
    disclosureButton.alpha = 0
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    dateLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    menuButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    setHeader()
    
    super.traitCollectionDidChange(previousTraitCollection)
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                      forTextStyle: .footnote)
    guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
    setNeedsLayout()
    constraint.constant = textView.contentSize.height
    layoutIfNeeded()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    item = nil
    //    commentThreadSubject = .init(nil)
    //    replySubject = .init(nil)
    //    claimSubject = .init(nil)
    //    deleteSubject = .init(nil)
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
      horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor),// constant: padding),
      //            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),// constant: padding),
      horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),// constant: padding),
    ])
    
    let constraint = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    constraint.identifier = "leadingAnchor"
    constraint.isActive = true
    
    //        openConstraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    //        openConstraint.priority = .defaultLow
    
    //        let bottomAnchor = repliesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    //        bottomAnchor.priority = .defaultLow
    //        bottomAnchor.isActive = true
  }
  
  @MainActor
  func updateUI() {
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
        actions = [claimAction, replyAction]
      }
      
      return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
    }
    
    menuButton.menu = prepareMenu()
    menuButton.showsMenuAsPrimaryAction = true
    
    switch mode {
    case .Plain, .Child:
      verticalStack.addArrangedSubview(repliesView)
      repliesView.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true
      let bottomAnchor = repliesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
      bottomAnchor.identifier = "bottomAnchor"
      bottomAnchor.priority = .defaultHigh
      bottomAnchor.isActive = true
    case .Root:
      guard !item.isOwn else { return }
      
      verticalStack.removeArrangedSubview(repliesView)
      repliesView.removeFromSuperview()
      verticalStack.addArrangedSubview(replyLabel)
      replyLabel.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true
      let bottomAnchor = replyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
      bottomAnchor.identifier = "bottomAnchor"
      bottomAnchor.priority = .defaultHigh
      bottomAnchor.isActive = true
    }
    
    if item.isOwn {
//      repliesView.alpha = item.replies > 0 ? 1 : 0
      replyButton.removeFromSuperview()
//    } else {
//      repliesView.alpha = 1
    }
    
    setHeader()
    setBody()
    
    replyButton.alpha = item.isOwn ? 0 : 1
    
    if let userprofile = item.userprofile {
      avatar.userprofile = userprofile.isCurrent ? Userprofiles.shared.current : userprofile
      if let answer = item.answer,
         let image = UIImage(systemName: "\(answer.order+1).circle.fill") {
        avatar.setChoiceBadge(image: image, color: Colors.getColor(forId: answer.order))
      }
    } else {
      avatar.userprofile = Userprofile.anonymous
    }
//    disclosureButton.alpha = 0
    
//    if mode == .Root, item.replies != 0 {
//      disclosureButton.alpha = 1
    let attrString = NSMutableAttributedString(string: " \(item.replies) " + "replies_total".localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.systemBlue
      ])
      disclosureButton.setAttributedTitle(attrString, for: .normal)
//    }
    
    if mode == .Child {
      disclosureButton.alpha = 0
    }
    
    guard let constraint = horizontalStack.getConstraint(identifier: "leadingAnchor") else { return }
    
    setNeedsLayout()
    constraint.constant = mode == .Child ? padding*2 : 0//avatar.bounds.width/2 : 0
    layoutIfNeeded()
  }
  
  func setHeader() {
    let attrString = NSMutableAttributedString()
    if !item.isAnonymous, let userprofile = item.userprofile {
      if !userprofile.firstNameSingleWord.isEmpty {
        let instance = NSAttributedString(string: userprofile.firstNameSingleWord + " ",
                                          attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
                                                       NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
        attrString.append(instance)
        if !userprofile.lastNameSingleWord.isEmpty {
          let lastname = NSAttributedString(string: userprofile.lastNameSingleWord + " ",
                                            attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
                                                         NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
          attrString.append(lastname)
        }
      } else {
        let instance = NSAttributedString(string: userprofile.lastNameSingleWord + " ",
                                          attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
                                                       NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
        attrString.append(instance)
      }
    } else {
      let instance = NSAttributedString(string: item.anonUsername + " ",
                                        attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
                                                     NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
      attrString.append(instance)
    }
    let date = NSAttributedString(string: item.createdAt.timeAgoDisplay(),
                                  attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2) as Any,
                                               NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
    attrString.append(date)
    dateLabel.attributedText = attrString
  }
  
  func setBody() {
    if mode == .Child {
      let attrString = NSMutableAttributedString()
      if let survey = item.survey, survey.isAnonymous, let reply = item.replyTo {
        let reply = NSAttributedString(string: "@" + reply.anonUsername, attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.systemBlue
        ])
        attrString.append(reply)
      } else if let replyItem = item.replyTo, !replyItem.isParentNode, let userprofile = replyItem.userprofile {
        if !userprofile.firstNameSingleWord.isEmpty || !userprofile.lastNameSingleWord.isEmpty {
          var reply: NSAttributedString!
          if !userprofile.firstNameSingleWord.isEmpty {
            reply = NSAttributedString(string: "@" + userprofile.firstNameSingleWord, attributes: [
              NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
              NSAttributedString.Key.foregroundColor: UIColor.systemBlue
            ])
          } else if !userprofile.lastNameSingleWord.isEmpty {
            reply = NSAttributedString(string: "@" + userprofile.lastNameSingleWord, attributes: [
              NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
              NSAttributedString.Key.foregroundColor: UIColor.systemBlue
            ])
          }
          attrString.append(reply)
        }
      }
      
      if item.isBanned {
        textView.text = "comment_is_banned".localized
        textView.textColor = .secondaryLabel
      } else if item.isDeleted {
        textView.text = "comment_is_deleted".localized
        textView.textColor = .secondaryLabel
      } else {
        let body = NSAttributedString(string: " " + item.body, attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.label
        ])
        
        attrString.append(body)
        textView.attributedText = attrString
      }
    } else {
      if item.isBanned {
        textView.text = "comment_is_banned".localized
        textView.textColor = .secondaryLabel
      } else if item.isDeleted {
        textView.text = "comment_is_deleted".localized
        textView.textColor = .secondaryLabel
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
