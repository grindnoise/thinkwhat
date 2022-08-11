//
//  PollMediaCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    // MARK: - Overriden Properties
    override var isSelected: Bool { didSet { updateAppearance() } }
    var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            color = item.topic.tagColor
            createSlides(mediafiles: item.media)// item.imagesCount)
            slides.forEach { [weak self] slide in
                guard let self = self, let mediafile = slide.mediafile else { return }
                guard let image = mediafile.image else {
                    mediafile.downloadImage(downloadProgress: { progress in
                        slide.imageView.progressIndicatorView.progress = progress
                    }) {
                        switch $0 {
                        case .success:
                            slide.imageView.image = mediafile.image
                            slide.imageView.progressIndicatorView.reveal()
                            slide.showTitle()
                            guard self.slides.first == slide else { return }
                            self.showPageControl()
                        case .failure(let error):
#if DEBUG
                            error.printLocalized(class: type(of: self), functionName: #function)
#endif
                            self.callbackDelegate?.callbackReceived(AppError.imageDownload)
                        }
                    }
                    return
                }
                slide.imageView.image = image
                slide.imageView.progressIndicatorView.alpha = 0
                slide.showTitle()
                self.showPageControl()
            }
        }
    }
    
    // MARK: - Public Properties
    public weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Private Properties
    private lazy var disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        instance.text = "images".localized.uppercased()
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
        constraint.identifier = "width"
        constraint.isActive = true
        
        return instance
    }()
    private lazy var disclosureIndicator: UIImageView = {
        let instance = UIImageView()
        instance.image = UIImage(systemName: "chevron.down")
        instance.tintColor = .secondaryLabel
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.contentMode = .center
        instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        
        return instance
    }()
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        
        let innerView = UIView()
        innerView.backgroundColor = .clear
        
        instance.addSubview(innerView)
        innerView.addSubview(horizontalStack)
        
        innerView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerView.topAnchor.constraint(equalTo: instance.topAnchor),
            innerView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            innerView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.95),
            innerView.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            horizontalStack.topAnchor.constraint(equalTo: innerView.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: innerView.bottomAnchor, constant: -10),
            horizontalStack.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: 10),
//            horizontalStack.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -10),
        ])
        
        return instance
    }()
    private lazy var icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "photo.fill"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            
            view.image = UIImage(systemName: "photo.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
        }))
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        instance.alignment = .center
        let constraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
        constraint.identifier = "height"
        constraint.isActive = true
        instance.spacing = 4
        instance.axis = .horizontal
//        instance.distribution = .fillProportionally
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [headerContainer, imageContainer])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    private lazy var imageContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
//        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1.0/1.0).isActive = true
        observers.append(instance.observe(\UITextView.bounds, options: .new, changeHandler: { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        }))
        return instance
    }()
    private lazy var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.delegate = self
        instance.isScrollEnabled = true
        instance.isPagingEnabled = true
        instance.showsHorizontalScrollIndicator = false
        instance.layer.masksToBounds = false
        instance.addEquallyTo(to: imageContainer)
        return instance
    }()
    private lazy var imagesStack: UIStackView = {
        let instance = UIStackView()
        scrollView.addSubview(instance)
        instance.distribution = .fillEqually
        instance.spacing = 0
        instance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instance.topAnchor.constraint(equalTo: scrollView.topAnchor),
            instance.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            instance.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            instance.heightAnchor.constraint(equalTo: imageContainer.heightAnchor),
        ])
        let width = instance.widthAnchor.constraint(equalToConstant: 100)
        width.identifier = "width"
        width.isActive = true
        return instance
    }()
    private var slides: [Slide] = []
    private lazy var pages: UILabel = {
        let instance = UILabel()
        instance.alpha = 0
        imageContainer.addSubview(instance)
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .callout)
        instance.backgroundColor = .black.withAlphaComponent(0.8)
        instance.textColor = .white
        instance.textAlignment = .center
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.layer.zPosition = 10
        NSLayoutConstraint.activate([
            instance.widthAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 0.15),
            instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 3.5/6.0),
            instance.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 20),
            instance.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -20),
        ])
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private var pageIndex: Int = 0
    private let padding: CGFloat = 0
    // Constraints
    private var closedConstraint: NSLayoutConstraint!
    private var openConstraint: NSLayoutConstraint!
    private var color: UIColor = .systemBlue {
        didSet {
//            disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//            disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//            guard let imageView = icon.get(all: UIImageView.self).first else { return }
//            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
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
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        
        setNeedsLayout()
        layoutIfNeeded()
        
        closedConstraint =
        horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        closedConstraint.priority = .defaultLow
        
        openConstraint =
            imageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        openConstraint.priority = .defaultLow
        
        updateAppearance(animated: false)
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance(animated: Bool = true) {
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
    
    private func showPageControl(animated: Bool = true) {
        guard slides.count > 1 else { return }
            pages.text = "\(pageIndex+1)/\(slides.count)"
            if animated {
                pages.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
                    self.pages.alpha = 1
                    self.pages.transform = .identity
                })
            } else {
                pages.alpha = 1
            }
    }
    
    private func createSlides(mediafiles: [Mediafile]) {
        mediafiles.sorted { $0.order < $1.order}.forEach {
                
            
            guard let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as? Slide else { return }
            let opaqueView = UIView()
            opaqueView.backgroundColor = .clear
            opaqueView.layer.masksToBounds = false
            
            let shadowView = UIView()
           
            shadowView.layer.masksToBounds = false
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
            shadowView.layer.shadowRadius = 4
            shadowView.layer.shadowOffset = .zero
//            shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: 1.0/1.0).isActive = true
            
//            shadowView.addEquallyTo(to: opaqueView, multiplier: 0.95)
            opaqueView.addSubview(shadowView)
            shadowView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                shadowView.topAnchor.constraint(equalTo: opaqueView.topAnchor),
                shadowView.widthAnchor.constraint(equalTo: opaqueView.widthAnchor, multiplier: 0.95),
                shadowView.centerXAnchor.constraint(equalTo: opaqueView.centerXAnchor),
                shadowView.bottomAnchor.constraint(equalTo: opaqueView.bottomAnchor)
            ])
            
//            let constraint = shadowView.bottomAnchor.constraint(equalTo: opaqueView.bottomAnchor)
//            constraint.priority = .defaultLow
//            constraint.isActive = true
            
            let bg = UIView()
            bg.accessibilityIdentifier = "bg"
            bg.backgroundColor = .systemBackground
            bg.addEquallyTo(to: shadowView)
            
            slide.mediafile = $0
            slide.color = item.topic.tagColor
            slide.frame = .zero
            slide.imageView.isUserInteractionEnabled = false
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(self.imageTapped(recognizer:)))
            slide.addGestureRecognizer(recognizer)
            slide.imageView.cornerRadius = imageContainer.cornerRadius
            slide.cornerRadius = imageContainer.cornerRadius
            slide.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
            slide.layer.masksToBounds = true
            slides.append(slide)
            slide.translatesAutoresizingMaskIntoConstraints = false
//            slide.addEquallyTo(to: opaqueView, multiplier: 0.95)
//            slide.addEquallyTo(to: shadowView, multiplier: 0.95)
                        slide.addEquallyTo(to: bg)
            //            slide.widthAnchor.constraint(equalTo: slide.heightAnchor, multiplier: 1.0/1.0).isActive = true
            imagesStack.addArrangedSubview(opaqueView)
        }
        imagesStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow"}).forEach {
            self.observers.append($0.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.height*0.05).cgPath
                //                view.layer.shadowColor = UIColor.red.withAlphaComponent(0.6).cgColor
            })
        }
        imagesStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "bg"}).forEach {
            self.observers.append($0.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.cornerRadius = newValue.height*0.05
            })
        }
        guard let constraint = imagesStack.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
        constraint.constant = imageContainer.frame.width * CGFloat(mediafiles.count)// + CGFloat(mediafiles.count) * imagesStack.spacing
    }

    @objc
    private func imageTapped(recognizer: UITapGestureRecognizer) {
        guard let slide = recognizer.view as? Slide,
              let mediafile = slide.mediafile,
              !mediafile.image.isNil else { return }
        callbackDelegate?.callbackReceived(slide.mediafile as AnyObject)
    }
    
    private func setObservers() {
        
        observers.append(imagesStack.observe(\UIStackView.bounds, options: .new) { [weak self] view, change in
            guard let self = self, let value = change.newValue, !self.item.isNil else { return }
            self.scrollView.contentSize.width = value.width// + CGFloat(self.item.imagesCount) * view.spacing
        })
        observers.append(pages.observe(\UILabel.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height * 0.25
//            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.5)
        })
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
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
//        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        if let imageView = icon.get(all: UIImageView.self).first {
//            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
        scrollView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .caption1)
        guard let constraint = horizontalStack.getConstraint(identifier: "height"),
              let constraint_2 = disclosureLabel.getConstraint(identifier: "width")
        else { return }
        setNeedsLayout()
        constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
        constraint_2.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
        layoutIfNeeded()
    }
    
    // MARK: - Public methods
    public func scrollToImage(at position: Int) {
        guard let destinationView = imagesStack.get(all: Slide.self).filter({ $0.mediafile?.order == position }).first?.superview else { return  }
        scrollView.scrollRectToVisible(destinationView.frame, animated: false)
    }
}

// MARK: - UISCrollViewDelegate
extension ImageCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageIndex = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        pages.text = "\(pageIndex+1)/\(slides.count)"
    }
}
