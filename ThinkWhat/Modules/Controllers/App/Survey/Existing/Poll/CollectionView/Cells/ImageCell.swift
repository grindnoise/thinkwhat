//
//  PollMediaCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var item: Survey! {
        didSet {
            guard !item.isNil else { return }
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
            }
        }
    }
    
    // MARK: - Private Properties
    private let imageContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.delegate = self
        instance.isScrollEnabled = true
        instance.isPagingEnabled = true
        instance.showsHorizontalScrollIndicator = false
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
    
    // MARK: - Public Properties
    public weak var callbackDelegate: CallbackObservable?
    
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
        contentView.addSubview(imageContainer)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),//, constant: padding),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            imageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        let constraint = imageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        setNeedsLayout()
        layoutIfNeeded()
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
            imagesStack.addArrangedSubview(opaqueView)
            slide.mediafile = $0
            slide.color = item.topic.tagColor
            slide.frame = .zero
            slide.imageView.isUserInteractionEnabled = false
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(self.imageTapped(recognizer:)))
            slide.addGestureRecognizer(recognizer)
            slide.imageView.cornerRadius = imageContainer.cornerRadius
            slide.cornerRadius = imageContainer.cornerRadius
            slide.backgroundColor = .secondarySystemBackground
            slide.layer.masksToBounds = true
            slides.append(slide)
            slide.translatesAutoresizingMaskIntoConstraints = false
            slide.widthAnchor.constraint(equalTo: slide.heightAnchor, multiplier: 1.0/1.0).isActive = true
            slide.addEquallyTo(to: opaqueView, multiplier: 0.95)
        }
        guard let constraint = imagesStack.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
        constraint.constant = imageContainer.frame.width * CGFloat(mediafiles.count)// + CGFloat(mediafiles.count) * imagesStack.spacing
    }
//    private func createSlides(count: Int) {
//        for _ in 0..<count {
//            guard let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as? Slide else { return }
//            slide.mediafile =
//            slide.color = item.topic.tagColor
//            slide.frame = .zero
////            slide.imageView.backgroundColor = .secondarySystemBackground
//            let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(recognizer:)))
//            slide.imageView.addGestureRecognizer(recognizer)
//            slide.imageView.cornerRadius = imageContainer.cornerRadius
//            slide.cornerRadius = imageContainer.cornerRadius
//            slide.backgroundColor = .secondarySystemBackground
//            slide.layer.masksToBounds = true
//            slides.append(slide)
//            imagesStack.addArrangedSubview(slide)
//        }
//        guard let constraint = imagesStack.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
//        constraint.constant = imageContainer.frame.width * CGFloat(count)
//    }
    
    @objc
    private func imageTapped(recognizer: UITapGestureRecognizer) {
        guard let slide = recognizer.view as? Slide,
              let mediafile = slide.mediafile,
              !mediafile.image.isNil else { return }
        callbackDelegate?.callbackReceived(slide.mediafile as AnyObject)
    }
    
    private func setObservers() {
        observers.append(imageContainer.observe(\UITextView.bounds, options: .new, changeHandler: { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        }))
        observers.append(imagesStack.observe(\UIStackView.bounds, options: .new) { [weak self] view, change in
            guard let self = self, let value = change.newValue, !self.item.isNil else { return }
            self.scrollView.contentSize.width = value.width// + CGFloat(self.item.imagesCount) * view.spacing
        })
        observers.append(pages.observe(\UILabel.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height * 0.25
            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.5)
        })
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
    
    // MARK: - Public methods
    func scrollToImage(at position: Int) {
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
