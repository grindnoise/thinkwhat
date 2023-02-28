//
//  LanguageListViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class LanguageListViewController: UIViewController {

    // MARK: - Properties
    var controllerOutput: LanguageListControllerOutput?
    var controllerInput: LanguageListControllerInput?
    
    
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = LanguageListView()
        let model = LanguageListModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        title = "content_language".localized
        
        setRightBarButton()
    }
}

private extension LanguageListViewController {
    func setRightBarButton() {
        
        let button = UIBarButtonItem(image: UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap))
        
        navigationItem.setRightBarButton(button, animated: true)
    }
    
    @objc
    func handleTap() {
        let banner = Popup()
        banner.present(content: PopupContent(parent: banner,
                                             systemImage: "globe",
                                             text: "content_language_hint".localized,
                                             buttonTitle: "ok",
                                             fixedSize: false,
                                             spacing: 24))
    }
}

extension LanguageListViewController: LanguageListViewInput {
    func updateContentLanguage(language: LanguageItem, use: Bool) {
        controllerInput?.updateContentLanguage(language: language, use: use)
    }
}

extension LanguageListViewController: LanguageListModelOutput {}

extension LanguageListViewController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}
