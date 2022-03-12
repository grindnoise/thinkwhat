//
//  AgreementView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import WebKit

class AgreementView: UIView {
    
    deinit {
        print("AgreementView deinit")
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.delegate = self
            webView.navigationDelegate = self
        }
    }
    @IBOutlet weak var acceptButton: UIButton! {
        didSet {
            acceptButton.setTitle("", for: .normal)
            acceptButton.backgroundColor = K_COLOR_GRAY
            let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                  size: CGSize(width: acceptButton.frame.height,
                                                                               height: acceptButton.frame.height)))
            indicator.alpha = 0
            indicator.layoutCentered(in: acceptButton)
            indicator.startAnimating()
            indicator.color = .white
            UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        }
    }
    
    // MARK: - IB actions
    @IBAction func agreeButtonTapped(_ sender: Any) {
        if agreementIsLoading {
            viewInput?.onTapWhileLoading()
        } else {
            switch hasReadAgreement {
            case true:
                viewInput?.onAccept()
            case false:
                viewInput?.onRefuse()
            }
        }
    }
    
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
        guard let contentView = self.fromNib()
                    else { fatalError("View could not load from nib") }
                addSubview(contentView)

        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        guard acceptButton != nil else { return }
        acceptButton.cornerRadius = acceptButton.frame.height/2.25
    }
    
    // MARK: - Properties
    weak var viewInput: ConditionsViewInput?
    private var agreementIsLoading = true {
        didSet {
            guard !agreementIsLoading, !webView.isNil else { return }
            webView.scrollView.isScrollEnabled = true
        }
    }
    private var hasReadAgreement = false {
        didSet {
            if hasReadAgreement {
                UIView.animate(withDuration: 0.2) {
                    self.setAcceptButtonColor()
                }
            }
        }
    }
}

// MARK: - Controller Output
extension AgreementView: ConditionsControllerOutput {
    func getTermsConditionsURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
}

// MARK: - UI Setup
extension AgreementView {
    private func setAcceptButtonColor() {
        guard acceptButton != nil else { return }
        acceptButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return self.hasReadAgreement ? UIColor.systemBlue : K_COLOR_GRAY
            default:
                return self.hasReadAgreement ? K_COLOR_RED : K_COLOR_GRAY
            }
        }
    }
    
    private func setupUI() {
        setAcceptButtonColor()
    }
}

// MARK: - Web delegate
extension AgreementView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        agreementIsLoading = false
        guard acceptButton != nil, let indicator = acceptButton.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self)}).first as? UIActivityIndicatorView else { return }
        UIView.animate(withDuration: 0.2) {
            indicator.alpha = 0
        } completion: { _ in
            indicator.removeFromSuperview()
            self.acceptButton.setTitle(#keyPath(AgreementView.acceptButton).localized, for: .normal)
        }
    }
}

// MARK: - Scroll delegate
extension AgreementView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isScrollEnabled, !hasReadAgreement, (scrollView.contentOffset.y + scrollView.bounds.height) >= scrollView.contentSize.height {
            hasReadAgreement = true
        }
    }
}


