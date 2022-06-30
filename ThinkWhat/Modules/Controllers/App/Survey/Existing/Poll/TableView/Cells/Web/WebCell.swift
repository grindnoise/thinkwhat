//
//  WebCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import WebKit


class WebCell: UITableViewCell, WKNavigationDelegate, WKUIDelegate, CallbackObservable {
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if app == .TikTok {
            if UserDefaults.App.tiktokPlay == nil {
                return nil
            } else {
                return UserDefaults.App.tiktokPlay
            }
        }
        return nil
    }
    private var isTiTokInstalled: Bool {
        let appName = "tiktok"
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        return UIApplication.shared.canOpenURL(appUrl! as URL)
    }
    private var opaqueView: UIView?
    private weak var delegate: CallbackObservable?
    private var isSetupComplete = false
    private var url: URL!
    private var isContentLoading = false
    private var app: ThirdPartyApp  = .Null
    
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            opaqueView = UIView(frame: .zero)
            opaqueView!.backgroundColor = .clear
            opaqueView!.addEquallyTo(to: contentView)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(WebCell.viewTapped(recognizer: )))
            opaqueView!.addGestureRecognizer(recognizer)
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.alpha = 0
            webView.backgroundColor = .systemBackground
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.3, delay: 1, options: [.curveEaseInOut], animations: {
            self.webView.alpha = 1
        })
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
            print(html as Any)
        })
    }
    
    @objc private func viewTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            switch app {
            case .TikTok:
                if sideAppPreference == .App || tempAppPreference == .App {
                    if isTiTokInstalled {
                        UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
                    }
                } else if sideAppPreference == nil, tempAppPreference == nil, isTiTokInstalled {
                    delBanner.shared.contentType = .SideApp
                    if let content = delBanner.shared.content as? SideApp {
                        content.app = .TikTok
                        content.delegate = self
                    }
                    delBanner.shared.present(isModal: true, delegate: nil)
                }
            default:
                print("")
            }
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if sideAppPreference != nil {
            return sideAppPreference == .App ? false : true
        } else if tempAppPreference != nil {
            return tempAppPreference == .App ? false : true
        }
        return true
    }
    
    func callbackReceived(_ sender: Any) {
        if let option = sender as? SideAppPreference {
            switch option {
            case .App:
                tempAppPreference = .App
                UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
            case .Embedded:
                tempAppPreference = .Embedded
                opaqueView?.removeFromSuperview()
            }
        }
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, url _url: URL) {
        if !isSetupComplete {
            isSetupComplete = true
            setNeedsLayout()
            layoutIfNeeded()
            contentView.cornerRadius = contentView.frame.width * 0.05
            url = _url
            delegate = callbackDelegate
            if url.absoluteString.isTikTokLink {
                app = .TikTok
                guard !isContentLoading else {
                    return
                }
                isContentLoading = true
//                webView.url = url
                webView.load(URLRequest(url: url))
                if url.absoluteString.isTikTokEmbedLink {
                    var webContent = "<meta name='viewport' content='initial-scale=0.6, maximum-scale=0.6, user-scalable=no'/>"
                    webContent += url.absoluteString
                    webView.loadHTMLString(webContent, baseURL: URL(string: "http://www.tiktok.com")!)
                } else {
                    guard let embeddedURL = URL(string: "https://www.tiktok.com/oembed?url=\(url.absoluteString)") else {
                        callbackDelegate.callbackReceived(AppError.tikTokContent)
                        return
                    }
                    API.shared.getTikTokEmbedHTML(url: embeddedURL) { result in
                        switch result {
                        case .success(let json):
                            guard let html = json["html"].string else {
                                callbackDelegate.callbackReceived(AppError.tikTokContent)
                                return
                            }
                            var webContent = "<meta name='viewport' content='initial-scale=0.8, maximum-scale=0.8, user-scalable=no'/>"
                            webContent += html
                            self.webView.loadHTMLString(webContent, baseURL: URL(string: "http://www.tiktok.com")!)
                        case .failure(let error):
#if DEBUG
                            print(error.localizedDescription)
#endif
                            callbackDelegate.callbackReceived(AppError.tikTokContent)
                            return
                        }
                    }
                }
            }
            delegate = callbackDelegate
        }
    }
}

extension WebCell: BannerObservable {
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
