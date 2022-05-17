//
//  SubscribersController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubscribersController: UIViewController {

    deinit {
        print("SubscribersController deinit")
    }
    
    init(mode __mode: Mode) {
        self._mode = __mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Mode {
        case Subscriptions, Subscribers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SubscribersModel()
               
        self.controllerOutput = view as? SubscribersView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        setTitle()
        setBarButton()
        setToolBar()
        setupUI()
        setObservers()
        loadData()
    }
    
    private func setObservers() {
        switch mode {
        case .Subscriptions:
            NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscribedForUpdated), name: Notifications.Userprofiles.SubscribedForUpdated, object: nil)
        case.Subscribers:
            NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscribedForUpdated), name: Notifications.Userprofiles.SubscribersUpdated, object: nil)
        }
    }
    
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func loadData() {
        switch mode {
        case .Subscriptions:
            controllerInput?.loadSubscriptions()
        case.Subscribers:
            controllerInput?.loadSubscribers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func setToolBar() {
        guard mode == .Subscriptions else { return }
        self.navigationController?.isToolbarHidden = true
        var items = [UIBarButtonItem]()
        items.append(
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(
            UIBarButtonItem(title: "unsubscribe".localized, style: .plain, target: self, action: #selector(self.unsubscribeTapped))
        )
        toolbarItems = items
    }
    
    private func setBarButton() {
        guard _mode == .Subscriptions else { return }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SubscribersController.switchEditing))
        barButton.addGestureRecognizer(gesture)
        barButton.contentMode = .scaleAspectFit
        barButton.image = ImageSigns.pencilCircle.image
        barButton.tintColor = .systemGray
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: barButton)]
    }
    
    private func setTitle() {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        let text = _mode == .Subscribers ? "subscribers" : "subscribed_for"
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: text.localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attrString.append(NSAttributedString(string: "\n\(controllerInput!.userprofiles.count)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        label.attributedText = attrString
        navigationItem.titleView = label
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.tintColor = navigationController?.isToolbarHidden == true ? .systemGray : .systemBlue
    }
    
    private func unsubscribe() {
        guard let list = controllerOutput?.unsubscribeList else { return }
        controllerInput?.unsubscribe(list)
        navigationController?.setToolbarHidden(true, animated: true)
        UIView.transition(with: barButton, duration: 0.3, options: [.transitionCrossDissolve]) {
            self.barButton.image = ImageSigns.pencilCircle.image
            self.barButton.tintColor = .systemGray
        } completion: { _ in
            self.controllerOutput?.disableEditing()
        }
    }
    
    @objc
    private func onSubscribedForUpdated() {
        controllerOutput?.onSubscribedForUpdated()
    }
    
    @objc
    private func cancel() {
        navigationController?.setToolbarHidden(true, animated: true)
        UIView.transition(with: barButton, duration: 0.3, options: [.transitionCrossDissolve]) {
            self.barButton.image = ImageSigns.pencilCircle.image
            self.barButton.tintColor = .systemGray
        } completion: { _ in
            self.controllerOutput?.disableEditing()
        }
    }
    
    @objc
    private func unsubscribeTapped() {
        showPopup(callbackDelegate: self,
                  bannerDelegate: self,
                  subview: Confirm(imageContent: ImageSigns.questionmarkDiamondFilled,
                                   text: "unsubscribe_question",
                                   buttonTitle: "unsubscribe",
                                   identifier: "unsubscribe")
                  )
    }
    
    @objc
    private func switchEditing() {
        isEditingEnabled = !isEditingEnabled
        UIView.transition(with: barButton, duration: 0.3, options: [.transitionCrossDissolve]) {
            self.barButton.image = self.isEditingEnabled ? ImageSigns.pencilCircleFilled.image : ImageSigns.pencilCircle.image
            self.barButton.tintColor = self.isEditingEnabled ? .systemBlue : .systemGray
        } completion: { _ in }
        navigationController?.setToolbarHidden(isEditingEnabled ? false : true, animated: true)
        guard isEditingEnabled else {
            controllerOutput?.disableEditing()
            return
        }
        controllerOutput?.enableEditing()
    }

    // MARK: - Properties
    var controllerOutput: SubscribersControllerOutput?
    var controllerInput: SubscribersControllerInput?
    private let _mode: Mode
    private let barButton = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
    private var isEditingEnabled = false
}

// MARK: - View Input
extension SubscribersController: SubscribersViewInput {
    var userprofiles: [Userprofile] {
        return controllerInput?.userprofiles ?? []
    }
    
    var mode: Mode {
        return _mode
    }
}

// MARK: - Model Output
extension SubscribersController: SubscribersModelOutput {
    func onAPIError() {
        controllerOutput?.onAPIError()
    }
}

extension SubscribersController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let btn = sender as? UIButton {
            if btn.accessibilityIdentifier == "unsubscribe" {
                unsubscribe()
            }
        }
    }
}

extension SubscribersController: BannerObservable {
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
