//
//  ListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ListView: UIView {
    
    weak var viewInput: ListViewInput?
    
    // MARK: - Private properties
    private lazy var collectionView: (SurveysCollection & SurveyDataSource) = {
        let instance = SurveysCollection(delegate: self, category: .New)
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private var notifications: [Task<Void, Never>?] = []
//    private var hMaskLayer: CAGradientLayer!
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        instance.addEquallyTo(to: shadowView)
        collectionView.addEquallyTo(to: instance)
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        return instance
    }()

    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.layer.masksToBounds = false
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            shadowView.layer.shadowRadius = 5
            shadowView.layer.shadowOffset = .zero
            observers.append(shadowView.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
            })
            background.addEquallyTo(to: shadowView)
        }
    }
    
    // MARK: - Destructor
    deinit {
        ///Destruct notifications
        notifications.forEach { $0?.cancel() }
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
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {    
    func onError() {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark, dismissAfter: 1)
    }
    
    func onDataSourceChanged() {
        guard let category = viewInput?.surveyCategory else { return }
        collectionView.category = category
    }
    
    func onDidLoad() {
        collectionView.reload()
    }
    
    func onDidLayout() {}
}

// MARK: - UI Setup
extension ListView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
    }
}

extension ListView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instance = sender as? SurveyReference {
            viewInput?.onSurveyTapped(instance)
        } else if sender is SurveysCollection {
            viewInput?.onDataSourceRequest()
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
