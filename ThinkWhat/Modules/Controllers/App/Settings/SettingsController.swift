//
//  SettingsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices

class SettingsController: UIViewController {
    
    enum Mode {
        case Profile, Settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SettingsModel()
               
        self.controllerOutput = view as? SettingsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        navigationItem.title = "profile".localized
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(settingsSwitch)
        settingsSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsSwitch.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            settingsSwitch.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            settingsSwitch.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState * 0.97),
            settingsSwitch.widthAnchor.constraint(equalTo: settingsSwitch.heightAnchor, multiplier: 3)
            ])
    }

    // MARK: - Properties
    var controllerOutput: SettingsControllerOutput?
    var controllerInput: SettingsControllerInput?
    
    var mode: SettingsController.Mode = .Profile
    private lazy var settingsSwitch: SettingsSwitch = {
        return SettingsSwitch(callbackDelegate: self)
    }()
}

// MARK: - View Input
extension SettingsController: SettingsViewInput {
    func updateGender(_ gender: Gender) {
        let parameters = API.prepareUserData(gender: gender)
        controllerInput?.updateUserprofile(parameters: parameters, image: nil)
    }
    
    func updateBirthDate(_ date: Date) {
        let parameters = API.prepareUserData(birthDate: dateFormatter.string(from: date))
        controllerInput?.updateUserprofile(parameters: parameters, image: nil)
    }
    
    func updateUsername(_ dict: [String : String]) {
        let parameters = API.prepareUserData(firstName: dict.keys.first, lastName: dict.values.first)
        controllerInput?.updateUserprofile(parameters: parameters, image: nil)
    }
    
    func onSocialTapped(_ url: URL) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
}

// MARK: - Model Output
extension SettingsController: SettingsModelOutput {
    func onError(_ error: Error) {
        controllerOutput?.onError(error)
    }
}

extension SettingsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SettingsController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let state = sender as? SettingsSwitch.State {
            switch state {
            case .Profile:
                mode = .Profile
                navigationItem.title = "profile".localized
            case .Settings:
                mode = .Settings
                navigationItem.title = "settings".localized
            }
        }
    }
}
