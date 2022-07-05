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
    ///Внимание, вызывается из collectionView.didSelect!
    override var isSelected: Bool { didSet { updateAppearance() } }
    var url: URL? {
        didSet {
            guard !url.isNil else { return }
            if url!.absoluteString.isTikTokLink, isTiTokInstalled {
                app = .TikTok
                opaqueView = UIView(frame: .zero)
                opaqueView!.backgroundColor = .clear
                opaqueView!.addEquallyTo(to: contentView)
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(WebViewCell.viewTapped(recognizer: )))
                opaqueView!.addGestureRecognizer(recognizer)
            }
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
    private var isTiTokInstalled: Bool {
        let appName = "tiktok"
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        return UIApplication.shared.canOpenURL(appUrl! as URL)
    }
    private var app: ThirdPartyApp  = .Null
    private var opaqueView: UIView?
    private let background: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = true
        instance.backgroundColor = .secondarySystemBackground
        return instance
    }()
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        return instance
    }()
    private lazy var browserButton: UIButton = {
        let instance = UIButton()
        instance.setImage(UIImage(systemName: "safari.fill"), for: .normal)
        instance.setTitle("open_in_safari".localized, for: .normal)
        instance.setTitleColor(UIColor.systemBlue, for: .normal)
        instance.tintColor = .systemBlue
        instance.addTarget(self, action: #selector(WebViewCell.openURL), for: .touchUpInside)
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [disclosureLabel, disclosureIndicator])
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, background, browserButton])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    private lazy var webView: WKWebView = {
        let instance = WKWebView()
        instance.backgroundColor = .secondarySystemBackground
        instance.addEquallyTo(to: background)
//        instance.uiDelegate = self
        instance.alpha = 0
        instance.navigationDelegate = self
        return instance
    }()
    private let padding: CGFloat = 0
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if UserDefaults.App.tiktokPlay == nil {
            return nil
        } else {
            return UserDefaults.App.tiktokPlay
        }
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
        horizontalStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            background.heightAnchor.constraint(equalTo: background.widthAnchor, multiplier: 1/1),
            browserButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        closedConstraint =
            disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            browserButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
        //Наоборот, тк изначально ячейка не выбрана, а надо развернуто показать
        disclosureLabel.text = !isSelected ? "hide_webview".localized.uppercased() : "show_webview".localized.uppercased()
        updateAppearance()
    }
    
    private func updateAppearance() {
        closedConstraint?.isActive = isSelected
        openConstraint?.isActive = !isSelected
        
        UIView.transition(with: disclosureLabel, duration: 0.1, options: .transitionCrossDissolve) { [unowned self] in
            //Наоборот, тк изначально ячейка не выбрана, а надо развернуто показать
            disclosureLabel.text = !isSelected ? "hide_webview".localized.uppercased() : "show_webview".localized.uppercased()
        } completion: { _ in }

        UIView.animate(withDuration: 0.3) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
        }
    }
    
    private func setObservers() {
        observers.append(background.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = max(value.height, value.width) * 0.05
        })
        observers.append(disclosureLabel.observe(\UILabel.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.3)
        }))
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
    
    @objc
    private func openURL() {
        callbackDelegate?.callbackReceived(url as Any)
    }
    
    @objc private func viewTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            switch app {
            case .TikTok:
                if sideAppPreference == .App || tempAppPreference == .App {
                    if isTiTokInstalled {
                        UIApplication.shared.open(url!, options: [:], completionHandler: {_ in})
                    }
                } else if sideAppPreference == nil, tempAppPreference == nil, isTiTokInstalled {
                    let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self)
                    let content = SideApp(app: .TikTok, callbackDelegate: banner)
                    banner.present(content: content, isModal: true)
                }
            default:
                print("")
            }
        }
    }
}

// MARK: - CallbackObservable
extension WebViewCell: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let preference = sender as? SideAppPreference {
            opaqueView?.removeFromSuperview()
            if preference == .App {
                tempAppPreference = .App
                UIApplication.shared.open(url!, options: [:], completionHandler: {_ in})
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
extension WebViewCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.2, delay: 1, options: [.curveEaseInOut], animations: {
            self.webView.alpha = 1
        })
//        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
//                                   completionHandler: { (html: Any?, error: Error?) in
//            print(html as Any)
//        })
    }
}
