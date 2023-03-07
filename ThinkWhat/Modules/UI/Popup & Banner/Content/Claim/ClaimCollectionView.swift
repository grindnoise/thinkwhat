//
//  ClaimCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ClaimCollectionView: UICollectionView, UICollectionViewDelegate {
    
    private enum Section { case main }
    
    // MARK: - Public properties
  @Published public var claim: Claim?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Collection
    private var source: UICollectionViewDiffableDataSource<Section, Claim>!
    private var dataItems: [Claim] {
        return Claims.shared.all
    }
    
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
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        delegate = self
        
        collectionViewLayout = UICollectionViewCompositionalLayout { _, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            layoutConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
            layoutConfig.showsSeparators = false//true
//            layoutConfig.headerMode = .supplementary
            layoutConfig.backgroundColor = .clear
            
            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
          sectionLayout.contentInsets = .uniform(size: 0)//NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
//            sectionLayout.interGroupSpacing = 16
            return sectionLayout
        }
        
        let cellRegistration = UICollectionView.CellRegistration<ClaimCell, Claim> { cell, indexPath, item in
            cell.item = item
            
            var config = UIBackgroundConfiguration.listPlainCell()
            config.backgroundColor = .clear
            cell.backgroundConfiguration = config
//            cell.automaticallyUpdatesBackgroundConfiguration = false
        }
        
        let headerRegistraition = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            
            var configuration = supplementaryView.defaultContentConfiguration()
            configuration.text = "choose_claim_reason".localized.uppercased()
            configuration.textProperties.font = UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .headline)!
            configuration.textProperties.color = .secondaryLabel
            configuration.textProperties.alignment = .center
            configuration.directionalLayoutMargins = .init(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
            
            var config = UIBackgroundConfiguration.listPlainCell()
            config.backgroundColor = .clear
            supplementaryView.backgroundConfiguration = config
//            supplementaryView.automaticallyUpdatesBackgroundConfiguration = false
            supplementaryView.contentConfiguration = configuration
            supplementaryView.automaticallyUpdatesContentConfiguration = false
        }
        
        source = UICollectionViewDiffableDataSource<Section, Claim>(collectionView: self) { collectionView, indexPath, itemIdentifier -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
//        source.supplementaryViewProvider = {
//            collectionView, elementKind, indexPath -> UICollectionReusableView? in
//
//            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistraition, for: indexPath)
//        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Claim>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClaimCell,
              let item = cell.item
        else { return }
        
      claim = item
    }
}

class ClaimCell: UICollectionViewListCell {
    
    // MARK: - Overriden properties
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            updateAppearance()
        }
    }
    
    // MARK: - Public properties
    public var item: Claim! {
        didSet {
            guard let item = item else { return }
            
            textView.text = item.description
//            guard let imageView = imageContainer.getSubview(type: UIImageView.self, identifier: "imageView"),
            guard let icon = imageContainer.getSubview(type: UIImageView.self, identifier: "icon"),
                  let constraint = icon.getConstraint(identifier: "heightAnchor"),
                  let font = textView.font
            else { return }
            
            setNeedsLayout()
            constraint.constant = min("1".height(withConstrainedWidth: 100, font: font), imageContainer.bounds.height)
            layoutIfNeeded()
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private lazy var imageContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear

        let icon = Icon()
        icon.accessibilityIdentifier = "icon"
        icon.backgroundColor = .clear
        icon.isRounded = false
        icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1).isActive = true
        icon.scaleMultiplicator = 0.8
        icon.iconColor = .systemGray2
        icon.category = .Oval
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        instance.addSubview(icon)
        icon.centerXAnchor.constraint(equalTo: instance.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: instance.centerYAnchor).isActive = true
        
        let constraint = icon.heightAnchor.constraint(equalToConstant: 10)
        constraint.identifier = "heightAnchor"
        constraint.isActive = true
//        let imageView = UIImageView(image: UIImage(systemName: "circle.fill"))
//        imageView.accessibilityIdentifier = "imageView"
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1/1).isActive = true
//        imageView.tintColor = .secondaryLabel
//        imageView.contentMode = .center
//
//        observers.append(imageView.observe(\UIImageView.bounds, options: .new) { view, change in
//            guard let newValue = change.newValue else { return }
//
//            view.image = UIImage(systemName: "circlebadge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height))
//        })
//
//        instance.addSubview(imageView)
//        imageView.centerXAnchor.constraint(equalTo: instance.centerXAnchor).isActive = true
//        imageView.centerYAnchor.constraint(equalTo: instance.centerYAnchor).isActive = true
//
//        let constraint = imageView.heightAnchor.constraint(equalToConstant: 10)
//        constraint.identifier = "heightAnchor"
//        constraint.isActive = true

        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
//        instance.contentInset = UIEdgeInsets(top: 0,
//                                             left: 0,//,instance.contentInset.left,
//                                             bottom: 0,
//                                             right: 0)//instance.contentInset.right)
        instance.isUserInteractionEnabled = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .clear
        instance.isEditable = false
        instance.isSelectable = false
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        
        observers.append(instance.observe(\UITextView.contentSize, options: .new) { [weak self] view, change in
            guard let self = self,
                  let constraint = view.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height// + self.padding*2
            self.layoutIfNeeded()
        })
        return instance
    }()
    private lazy var horizontalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [imageContainer, textView])
        instance.axis = .horizontal
        instance.spacing = 0
        
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.1).isActive = true
        
        return instance
    }()
    private let padding: CGFloat = 8
    
    // MARK: - Destructor
    deinit {
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
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear

        contentView.addSubview(horizontalStackView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        
        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func updateAppearance() {
        guard let icon = imageContainer.getSubview(type: Icon.self, identifier: "icon")
//            let destinationPath = (icon.getLayer(isSelected ? .ExclamationMark : .Oval) as? CAShapeLayer)?.path,
//            let finalPath = (isSelected ? destinationPath.getScaledPath(size: destinationPath.boundingBox.size, scaleMultiplicator: 0.65) : destinationPath) as? CGPath,
//            let shapeLayer = icon.icon as? CAShapeLayer
        else { return }
        
//        let pathAnim = Animations.get(property: .Path,
//                                      fromValue: shapeLayer.path as Any,
//                                      toValue: finalPath,
//                                      duration: isSelected ? 0.275 : 0.175,
//                                      delay: 0,
//                                      repeatCount: 0,
//                                      autoreverses: false,
//                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                                      delegate: nil,
//                                      isRemovedOnCompletion: true)
//        shapeLayer.add(pathAnim, forKey: nil)
//        shapeLayer.path = finalPath
        
        let colorAnim = Animations.get(property: .FillColor,
                                             fromValue: icon.iconColor.cgColor as Any,
                                             toValue: isSelected ? UIColor.systemRed.cgColor : UIColor.systemGray2.cgColor as Any,
                                             duration: 0.15,
                                             delay: 0,
                                             repeatCount: 0,
                                             autoreverses: false,
                                             timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                             delegate: nil,
                                             isRemovedOnCompletion: false)
        icon.icon.add(colorAnim, forKey: nil)

        
//        guard let imageView = imageContainer.getSubview(type: UIImageView.self, identifier: "imageView") else { return }
//
//        Animations.changeImageCrossDissolve(imageView: imageView,
//                                            image: UIImage(systemName: isSelected ? "hand.thumbsdown.fill" : "circlebadge.fill")!,
//                                            duration: 0.1,
//                                            animations: [{ [weak self] in
//            guard let self = self else { return }
//            switch self.isSelected {
//            case true:
//                imageView.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
//            case false:
//                imageView.tintColor = .secondaryLabel
//            }
//        }])
    }
}
