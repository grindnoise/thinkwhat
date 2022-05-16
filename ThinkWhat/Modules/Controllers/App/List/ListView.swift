//
//  ListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ListView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: ListViewInput?
    private var isSetupCompleted = false
    private var shadowPath: CGPath!
    private var list: (UIView & SurveyDataSource)! {
        didSet {
            list.addEquallyTo(to: card)
        }
    }
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var card: UIView! {
        didSet {
            card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var cardShadow: UIView!
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {
    func onError() {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, imageContent: ImageSigns.exclamationMark, shouldDismissAfter: 1)
    }
    
    func onDataSourceChanged() {
        guard let category = viewInput?.surveyCategory else { return }
        list.category = category
    }
    
    func onDidLoad() {
        
    }
    
    func onWillAppear() {
        if #available(iOS 14, *) {
            guard let v = card.subviews.filter({ $0.isKind(of: SurveysCollection.self) }).first as? SurveysCollection else { return }
            v.deselect()
        } else {
            guard let v = card.subviews.filter({ $0.isKind(of: SurveyTable.self) }).first as? SurveyTable else { return }
            v.deselect()
        }
    }
    
    func onDidLayout() {
        guard !isSetupCompleted else { return }
        isSetupCompleted = true
        ///Add shadow
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alpha = 0
        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
        cardShadow.layer.shadowPath = shadowPath
        cardShadow.layer.shadowRadius = 7
        cardShadow.layer.shadowOffset = .zero
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.alpha = 1
            self.transform = .identity
        } completion: { _ in }
    }
}

// MARK: - UI Setup
extension ListView {
    private func setupUI() {
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        card.layer.masksToBounds = true
        card.layer.cornerRadius = card.frame.width * 0.05
        alpha = 0

        if #available(iOS 14, *)  {
            list = SurveysCollection(delegate: self, category: .New)//(frame: card.bounds)
        } else {
            list = SurveyTable(delegate: self, category: .New)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

extension ListView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instance = sender as? SurveyReference {
            viewInput?.onSurveyTapped(instance)
        } else if #available(iOS 14, *) {
            if sender is SurveysCollection || sender is SurveyTable {
                viewInput?.onDataSourceRequest()
            }
        } else {
            if sender is SurveyTable {
                viewInput?.onDataSourceRequest()
            }
        }
    }
}

extension ListView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}
