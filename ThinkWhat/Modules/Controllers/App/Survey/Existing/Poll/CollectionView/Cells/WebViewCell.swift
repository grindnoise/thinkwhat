//
//  WebViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import WebKit

class WebViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var url: URL? {
        didSet {
            guard !url.isNil else { return }
            do {
                try webView.load(URLRequest(url: url!, method: .get))
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    // MARK: - Private Properties
    private lazy var webView: WKWebView = {
        let instance = WKWebView()
        instance.backgroundColor = .secondarySystemBackground
//        instance.delegate = self
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 0
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if UserDefaults.App.youtubePlay == nil {
            return nil
        } else {
            return UserDefaults.App.youtubePlay
        }
    }
    private var isYoutubeInstalled: Bool {
        let appName = "youtube"
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        return UIApplication.shared.canOpenURL(appUrl! as URL)
    }
    
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
        contentView.addSubview(webView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            webView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            webView.heightAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 1/1),
        ])
        let constraint = webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setObservers() {
        observers.append(webView.observe(\WKWebView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = max(value.height, value.width) * 0.05
        })
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
    
    private func openTiktokApp() {
        guard let id = url?.absoluteString.youtubeID else { return }
        let appScheme = "youtube://watch?v=\(id)"
        if let appUrl = URL(string: appScheme) {
            UIApplication.shared.open(appUrl)
        }
    }
}

// MARK: - CallbackObservable
extension WebViewCell: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let preference = sender as? SideAppPreference {
            if preference == .App {
                tempAppPreference = .App
                openTiktokApp()
            } else {
                tempAppPreference = .Embedded
            }
        }
    }
}


// MARK: - BannerObservable
extension WebViewCell: BannerObservable {
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

// MARK: - WKUIDelegate
extension WebViewCell: WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.3, delay: 1, options: [.curveEaseInOut], animations: {
            self.webView.alpha = 1
        })
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
            print(html as Any)
        })
    }
}
