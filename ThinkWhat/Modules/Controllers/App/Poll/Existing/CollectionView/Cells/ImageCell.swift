//
//  PollMediaCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ImageCell: UICollectionViewCell {
  
  // MARK: - Public properties
  var item: Survey! {
    didSet {
      guard !item.isNil else { return }
      
      updateUI()
    }
  }
  public var imagePublisher = PassthroughSubject<Mediafile, Never>()
  
  
  // MARK: - Overriden properties
  override var isSelected: Bool { didSet { updateAppearance() } }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "photo.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .scaleAspectFit
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Colors.cellHeader
    instance.text = "images".localized.uppercased()
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
//    let opaque = UIView()
//    opaque.backgroundColor = .clear
//    opaque.addSubview(horizontalStack)
//    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//    horizontalStack.leadingAnchor.constraint(equalTo: opaque.leadingAnchor, constant: padding).isActive = true
//    horizontalStack.topAnchor.constraint(equalTo: opaque.topAnchor).isActive = true
//    horizontalStack.bottomAnchor.constraint(equalTo: opaque.bottomAnchor).isActive = true
    
    let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, imageContainer])
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    return verticalStack
  }()
  private lazy var imageContainer: UIView = {
    let instance = UIView.opaque()
    instance.layer.masksToBounds = false
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
    instance.layer.shadowOffset = .zero
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowRadius = padding
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true//9/16).isActive = true
    
    return instance
  }()
  private lazy var scrollView: UIScrollView = {
    let instance = UIScrollView()
    instance.delegate = self
    instance.isScrollEnabled = true
    instance.isPagingEnabled = true
    instance.showsHorizontalScrollIndicator = false
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    instance.addEquallyTo(to: imageContainer)
    return instance
  }()
  private lazy var imagesStack: UIStackView = {
    let instance = UIStackView()
    scrollView.addSubview(instance)
    instance.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      instance.topAnchor.constraint(equalTo: scrollView.topAnchor),
      instance.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      instance.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      instance.heightAnchor.constraint(equalTo: imageContainer.heightAnchor),
    ])
    instance.distribution = .fillEqually
    instance.spacing = 0//padding*2
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.scrollView.contentSize.width = $0.width
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var images: [UIView] = []
  private lazy var pages: UILabel = {
    let instance = InsetLabel()
    instance.frame = .zero
    instance.insets = .uniform(size: 8)
    instance.alpha = 0
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .caption1)
    instance.backgroundColor = .black.withAlphaComponent(0.75)
    instance.textColor = .white
    instance.textAlignment = .center
    instance.text = "1"
    instance.layer.zPosition = 100
    imageContainer.addSubview(instance)
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: padding).isActive = true
    instance.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -padding).isActive = true
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.height*0.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var pageIndex: Int = 0
  private let padding: CGFloat = 8
  // Constraints
  private var closedConstraint: NSLayoutConstraint!
  private var openConstraint: NSLayoutConstraint!
  
  
  
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
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    imageContainer.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    //        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        if let imageView = icon.get(all: UIImageView.self).first {
    //            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        }
    
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
  
  // MARK: - Public methods
  public func scrollToImage(at position: Int) {
    guard imagesStack.arrangedSubviews.count >= position else { return  }
    
    scrollView.scrollRectToVisible(imagesStack.arrangedSubviews[position].frame, animated: false)
  }
}


// MARK: - Private
private extension ImageCell {
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
    
    setNeedsLayout()
    layoutIfNeeded()
    
    closedConstraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    closedConstraint.priority = .defaultLow
    
    openConstraint = imageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    openConstraint.priority = .defaultLow
    
    updateAppearance(animated: false)
  }
  
  /// Updates the views to reflect changes in selection
  func updateAppearance(animated: Bool = true) {
    closedConstraint?.isActive = isSelected
    openConstraint?.isActive = !isSelected
    
    guard animated else {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
      return
    }
    UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
    }
  }
  
  func updateUI() {
    item.media.sorted { $0.order < $1.order}.enumerated().forEach { index, media in
      let container = UIView()
      container.backgroundColor = .clear
      //            container.heightAnchor.constraint(equalTo: imagesStack.heightAnchor).isActive = true
      //            container.widthAnchor.constraint(equalTo: imagesStack.widthAnchor).isActive = true
      container.publisher(for: \.bounds)
        .filter { $0 != .zero }
        .sink { container.cornerRadius = $0.width*0.025 }
        .store(in: &subscriptions)
      
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFill
      imageView.place(inside: container)
      imageView.isUserInteractionEnabled = false
      imageView.layer.setValue(media, forKey: "media")
      imageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(self.imageTapped(recognizer:))))
      
      //            imageView.place(inside: imageContainer)
      let shimmer = Shimmer()//.secondarySystemBackground,
//                            darkColor: .systemGray5)//.tertiarySystemBackground)
      shimmer.place(inside: container)
      shimmer.startShimmering()
      
      //Text & button
      let textView = UITextView()
      textView.backgroundColor = .black.withAlphaComponent(0.75)
      textView.font = UIFont.scaledFont(fontName: Fonts.Rubik.Italic, forTextStyle: .subheadline)
      textView.textColor = .white
      textView.alpha = 0
      textView.text = media.title
      textView.isEditable = false
      textView.isSelectable = false
//      textView.publisher(for: \.bounds)
//        .filter { $0 != .zero }
//        .sink { textView.cornerRadius = $0.height*0.25 }
//        .store(in: &subscriptions)
      imageView.addSubview(textView)
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
      textView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
      textView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
      let textViewConstraint = textView.heightAnchor.constraint(equalToConstant: 1)
      textViewConstraint.identifier = "height"
      textViewConstraint.isActive = true
      
      let button = UIImageView()
      button.alpha = 0
      button.isUserInteractionEnabled = true
      button.backgroundColor = .black.withAlphaComponent(0.75)
      button.contentMode = .center
      button.tintColor = .white
      button.layer.setValue(false, forKey: "isSelected")
      button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.quoteTapped(sender:))))
      button.publisher(for: \.bounds)
        .filter { $0 != .zero }
        .sink {
          button.cornerRadius = $0.height*0.25
          
          guard let isSelected = button.layer.value(forKey: "isSelected") as? Bool else { return }
          
          button.image = UIImage(systemName: "quote.bubble.fill",//isSelected ? "quote.bubble" : "quote.bubble.fill",
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.35))
        }
        .store(in: &subscriptions)
      
      imageView.addSubview(button)
      
      
      button.translatesAutoresizingMaskIntoConstraints = false
      button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1/1).isActive = true
      let bottomConstraint = button.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -self.padding)
      bottomConstraint.isActive = true
//      bottomConstraint.identifier = "bottom"
      button.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -padding).isActive = true
      button.layer.setValue(media, forKey: "media")
      button.layer.setValue(imageView, forKey: "imageView")
      
      let buttonConstraint = button.heightAnchor.constraint(equalToConstant: 40) // "1".height(withConstrainedWidth: 100, font: pages.font))
      buttonConstraint.isActive = true
//      pages.publisher(for: \.bounds)
//        .filter { $0 != .zero }
//        .sink { buttonConstraint.constant = $0.height }
//        .store(in: &subscriptions)
      
      media.imagePublisher
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
          switch completion {
          case .finished:
#if DEBUG
            print("success")
#endif
          case .failure(let error):
#if DEBUG
            print(error)
#endif
          }
        }, receiveValue: { [weak self] in
          guard let self = self else { return }
          
//          UIView.animate(withDuration: 0.15, delay: 0, animations: {
//            shimmer.alpha = 0
//          }) { _ in
//            shimmer.stopShimmering(animated: true)
//            self.showPageControl { _ in
//              guard !media.title.isEmpty else { return }
//
//              self.showQuoteButton(button, animated: index == 0 ? true : false)
//            }
//            shimmer.removeFromSuperview()
//          }
          shimmer.stopShimmering(animated: true)
          self.showPageControl(animated: false) { _ in
            guard !media.title.isEmpty else { return }
            
            self.showQuoteButton(button, animated: false)
          }
          shimmer.removeFromSuperview()
          imageView.image = $0
          imageView.isUserInteractionEnabled = true
        })
        .store(in: &subscriptions)
      media.downloadImage()
      images.append(imageView)
      imagesStack.addArrangedSubview(container)
      container.heightAnchor.constraint(equalTo: imagesStack.heightAnchor).isActive = true
      container.widthAnchor.constraint(equalTo: imageContainer.widthAnchor).isActive = true
    }
  }
  
  @objc
  func imageTapped(recognizer: UITapGestureRecognizer) {
    guard let imageView = recognizer.view as? UIImageView,
          let media = imageView.layer.value(forKey: "media") as? Mediafile
    else { return }
    
    imagePublisher.send(media)
  }
  
  func showPageControl(animated: Bool = true, _ completion: @escaping (Bool) -> ()) {
    guard pages.alpha == 0 && images.count > 1 else {
      completion(true)
      return
    }
    
    pages.text = "\(pageIndex+1)/\(images.count)"
    if animated {
      pages.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      UIView.animate(withDuration: 0.15, delay: 0.15, options: .curveEaseInOut, animations: {[weak self] in
        guard let self = self else { return }
        
        self.pages.alpha = 1
        self.pages.transform = .identity
      }) { _ in completion(true) }
    } else {
      pages.alpha = 1
      completion(true)
    }
  }
  
  @objc
  func showQuoteButton(_ button: UIImageView, animated: Bool = true) {
    guard animated else {
      button.alpha = 1
      return
    }
    
    button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    UIView.animate(withDuration: 0.15, delay: 0.15, options: .curveEaseInOut) {
      button.alpha = 1
      button.transform = .identity
    }
  }
  
  
  @objc
  func quoteTapped(sender: UITapGestureRecognizer) {
    guard let button = sender.view as? UIImageView,
          let _isSelected = button.layer.value(forKey: "isSelected") as? Bool,
          let imageView = button.layer.value(forKey: "imageView") as? UIImageView,
          let textView = imageView.getSubview(type: UITextView.self),
//          let bottomConstraint = textView.getConstraint(identifier: "bottom"),
          let heightConstraint = textView.getConstraint(identifier: "height")
    else { return }
    
    let isSelected = !_isSelected
    
    button.layer.setValue(isSelected, forKey: "isSelected")
    imageView.setNeedsLayout()

    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
      textView.alpha = isSelected ? 1 : 0
//      bottomConstraint.constant = isSelected ? -self.padding : 0
      heightConstraint.constant = isSelected ? textView.contentSize.height : 0
      imageView.layoutIfNeeded()
    } completion: { _ in }
  }
  
  func setObservers() {
    
    //        scrollView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach { [weak self] in
    //            guard let self = self else { return }
    //            self.observers.append($0.observe(\UIView.bounds, options: .new) { view, change in
    //                view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.cornerRadius).cgPath
    //            })
    //        }
    //        observers.append(disclosureLabel.observe(\InsetLabel.bounds, options: .new) { [weak self] view, change in
    //            guard let self = self else { return }
    //            view.insets = UIEdgeInsets(top: view.insets.top, left: self.imageContainer.cornerRadius, bottom: view.insets.bottom, right: view.insets.right)
    ////            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.3)
    //        })
  }
}

// MARK: - UISCrollViewDelegate
extension ImageCell: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pageIndex = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
    pages.text = "\(pageIndex+1)/\(images.count)"
  }
}


//
//private func createSlides(mediafiles: [Mediafile]) {
//    mediafiles.sorted { $0.order < $1.order}.forEach {
//
//
//        guard let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as? Slide else { return }
//        let opaqueView = UIView()
//        opaqueView.backgroundColor = .clear
//        opaqueView.layer.masksToBounds = false
//
//        let shadowView = UIView()
//
//        shadowView.layer.masksToBounds = false
//        shadowView.clipsToBounds = false
//        shadowView.backgroundColor = .clear
//        shadowView.accessibilityIdentifier = "shadow"
//        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
//        shadowView.layer.shadowRadius = 4
//        shadowView.layer.shadowOffset = .zero
////            shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: 1.0/1.0).isActive = true
//
////            shadowView.addEquallyTo(to: opaqueView, multiplier: 0.95)
//        opaqueView.addSubview(shadowView)
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            shadowView.topAnchor.constraint(equalTo: opaqueView.topAnchor),
//            shadowView.widthAnchor.constraint(equalTo: opaqueView.widthAnchor, multiplier: 0.95),
//            shadowView.centerXAnchor.constraint(equalTo: opaqueView.centerXAnchor),
//            shadowView.bottomAnchor.constraint(equalTo: opaqueView.bottomAnchor)
//        ])
//
////            let constraint = shadowView.bottomAnchor.constraint(equalTo: opaqueView.bottomAnchor)
////            constraint.priority = .defaultLow
////            constraint.isActive = true
//
//        let bg = UIView()
//        bg.accessibilityIdentifier = "bg"
//        bg.backgroundColor = .systemBackground
//        bg.addEquallyTo(to: shadowView)
//
//        slide.mediafile = $0
//        slide.color = item.topic.tagColor
//        slide.frame = .zero
//        slide.imageView.isUserInteractionEnabled = false
//        let recognizer = UITapGestureRecognizer(target: self,
//                                                action: #selector(self.imageTapped(recognizer:)))
//        slide.addGestureRecognizer(recognizer)
//        slide.imageView.cornerRadius = imageContainer.cornerRadius
//        slide.cornerRadius = imageContainer.cornerRadius
//        slide.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
//        slide.layer.masksToBounds = true
//        slides.append(slide)
//        slide.translatesAutoresizingMaskIntoConstraints = false
////            slide.addEquallyTo(to: opaqueView, multiplier: 0.95)
////            slide.addEquallyTo(to: shadowView, multiplier: 0.95)
//                    slide.addEquallyTo(to: bg)
//        //            slide.widthAnchor.constraint(equalTo: slide.heightAnchor, multiplier: 1.0/1.0).isActive = true
//        imagesStack.addArrangedSubview(opaqueView)
//    }
//    imagesStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow"}).forEach {
//        self.observers.append($0.observe(\UIView.bounds, options: .new) { view, change in
//            guard let newValue = change.newValue else { return }
//            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.height*0.05).cgPath
//            //                view.layer.shadowColor = UIColor.red.withAlphaComponent(0.6).cgColor
//        })
//    }
//    imagesStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "bg"}).forEach {
//        self.observers.append($0.observe(\UIView.bounds, options: .new) { view, change in
//            guard let newValue = change.newValue else { return }
//            view.cornerRadius = newValue.height*0.05
//        })
//    }
//    guard let constraint = imagesStack.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
//    constraint.constant = imageContainer.frame.width * CGFloat(mediafiles.count)// + CGFloat(mediafiles.count) * imagesStack.spacing
//}
