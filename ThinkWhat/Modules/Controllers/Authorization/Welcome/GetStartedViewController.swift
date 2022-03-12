//
//  GetStartedViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import L10n_swift

protocol ToolbarPickerViewDelegate: class {
    func didTapDone()
    func didTapCancel()
}

class GetStartedViewController: UIViewController {
    
    deinit {
        print("GetStartedViewController deinit")
    }
    
    @IBOutlet var contentView: UIView!
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.hidesBackButton = true
        welcomeView = self.view as? WelcomeView
        welcomeView?.controller = self
//        var languageButton: UIBarButtonItem!
        if #available(iOS 14.0, *) {
            languageButton = UIBarButtonItem(title: Locale.current.localizedString(forLanguageCode: L10n.shared.language)?.capitalized,
                                             image: nil,
                                             primaryAction: UIAction(title: "") { _ in self.onLanguageTapped() },
                                             menu: nil)
        } else {
            languageButton = UIBarButtonItem(title: Locale.current.localizedString(forLanguageCode: L10n.shared.language)?.capitalized, style: .plain, target: self, action: #selector(onLanguageTapped))
        }
        languageButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: StringAttributes.FontStyle.Regular.rawValue,
                                                                                   size: 17.0)!],
                                              for: .normal)
        navigationItem.rightBarButtonItems = [languageButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isViewLayedOut {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    
    @objc private func onLanguageTapped() {
        guard !languageListOnScreen else { return }
        welcomeView?.onLanguageTapped()
    }

    // MARK: - Properties
    var welcomeView: WelcomeControllerOutput? {
        didSet {
            self.view = welcomeView as? UIView
        }
    }
    private var languageButton: UIBarButtonItem!
    private var isViewLayedOut = false
    private var languageListOnScreen = false {
        didSet {
            languageButton.isEnabled = !languageListOnScreen
        }
    }
    
}

// MARK: - View Input
extension GetStartedViewController: WelcomeViewInput {
    func onLanguageChanged(_ languageCode: String) {
        languageButton.title = Locale(identifier: languageCode).localizedString(forLanguageCode: languageCode)!.capitalized
    }
    
    func onLanguageChangeAccepted(_ languageCode: String) {
        Bundle.setLanguageAndPublish(languageCode, in: Bundle(for: Self.self))
    }
    
    func onLanguagesListPresented() {
        languageListOnScreen = !languageListOnScreen
    }
    
    func onGetStartedTap() {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Auth
            nav.duration = 0.5
        }
        navigationController?.pushViewController(SignupViewController(), animated: true)
    }
}


