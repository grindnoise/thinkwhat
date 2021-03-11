//
//  HyperlinkSelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.12.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class HyperlinkSelectionViewController: UIViewController {
    
    @IBOutlet weak var hyperlinkLabel: PaddingLabel! {
        didSet {
            hyperlinkLabel.font = font
            hyperlinkLabel.textColor = textColor
            hyperlinkLabel.tintColor = textColor
            hyperlinkLabel.backgroundColor = color.withAlphaComponent(0.25)
            if let str = hyperlink?.absoluteString {
                hyperlinkLabel.text = str
            } else {
                hyperlinkLabel.text = placeholder
            }
        }
    }
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    
    //    private var placeholder = NSAttributedString(string: "http://...", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 20), foregroundColor: UIColor.lightGray, backgroundColor: .clear))
    var placeholder: String = "ВСТАВИТЬ ССЫЛКУ"
    private var isAnimating = false
    private var isAnimationStopped = false
    var font: UIFont?
    var textColor: UIColor?
    var hyperlink: URL? {
        didSet {
            if hyperlink == nil {
                UIView.animate(withDuration: 0.2) {
//                    self.copySign.alpha = 1
                    self.trashSign.alpha = 0
                }
                if actionButton != nil {
//                    actionButton.isUserInteractionEnabled = false
                    actionButton.tagColor = K_COLOR_GRAY
                    isAnimationStopped = true
                    actionButton.textSize = 26
                    actionButton.text = "ПРОПУСТИТЬ"
                }
            } else {
                UIView.animate(withDuration: 0.2) {
//                    self.copySign.alpha = 0
                    self.trashSign.alpha = 1
                }
                isAnimationStopped = false
//                actionButton.isUserInteractionEnabled = true
                let anim = Animations.transformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut, delegate: self as CAAnimationDelegate)
                anim.setValue(self.actionButton, forKey: "btn")
                actionButton.layer.add(anim, forKey: nil)
                actionButton.tagColor = K_COLOR_RED
                actionButton.textSize = 43
                actionButton.text = "OK"
            }
        }
    }
    var _labelHeight: CGFloat = 0
    var color: UIColor!
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
//            actionButton.isUserInteractionEnabled = hyperlink == nil ? false : true
            actionButton.categoryID = .Text
            actionButton.tagColor   = hyperlink == nil ? K_COLOR_GRAY : K_COLOR_RED
            actionButton.text       = hyperlink == nil ? "ПРОПУСТИТЬ" : "OK"
            actionButton.textSize = hyperlink == nil ? 26 : 43
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
            actionButton.addGestureRecognizer(tap)
        }
    }
//    @IBAction func dismiss(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
//    @IBOutlet weak var hyperlinkLabel: UnderlinedTextField! {
//        didSet {
//            if let str = hyperlink?.absoluteString {
//                hyperlinkLabel.text = str
//            } else {
//                hyperlinkLabel.attributedText = placeholder
//            }
//        }
//    }
//    @IBOutlet weak var labelHeight: NSLayoutConstraint! {
//        didSet {
//            labelHeight.constant = _labelHeight
//            hyperlinkLabel.setNeedsLayout()
//            hyperlinkLabel.layoutIfNeeded()
//        }
//    }
//    @IBOutlet weak var rightSpacing: NSLayoutConstraint! {
//        didSet {
//            rightSpacing.constant = _labelHeight / 4
//        }
//    }
//    @IBOutlet weak var copySign: CopyPasteIcon! {
//        didSet {
//            copySign.alpha = hyperlink == nil ? 1 : 0
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            copySign.addGestureRecognizer(tap)
//        }
//    }
    @IBOutlet weak var trashSign: TrashIcon! {
        didSet {
            trashSign.alpha = hyperlink == nil ? 0 : 1
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
            trashSign.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var youtube: YoutubeLogo! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
            youtube.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var wiki: WikiLogo! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
            wiki.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var instagram: InstagramLogo! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
            instagram.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var safari: SafariLogo! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
            safari.addGestureRecognizer(tap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.duration = 0.32
            nc.transitionStyle = .Icon
        }
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isAnimationStopped = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if hyperlink != nil {
            isAnimationStopped = false
//            actionButton.isUserInteractionEnabled = true
            let anim = Animations.transformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut, delegate: self as CAAnimationDelegate)
            anim.setValue(self.actionButton, forKey: "btn")
            actionButton.layer.add(anim, forKey: nil)
        }
    }
    
    @objc fileprivate func somethingTapped(recognizer: UITapGestureRecognizer) {
        
        if let v = recognizer.view {
            switch v {
            case actionButton:
                isAnimationStopped = true
                if hyperlink == nil {
                    navigationController?.popViewController(animated: true)
                } else {
                    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                        self.actionButton.transform = .identity
                    }) {
                        _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
//            case copySign:
//                if let text = UIPasteboard.general.string, !text.isEmpty {
////                    hyperlinkLabel.attributedText = NSAttributedString(string: text, attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 20), foregroundColor: UIColor.black, backgroundColor: .clear))
//                    hyperlinkLabel.text = text
//                    if let url = URL(string: hyperlinkLabel.text!) as? URL {
//                        hyperlink = url
//                    } else {
//
//                    }
//                }
            case trashSign:
//                hyperlinkLabel.attributedText = placeholder
                hyperlinkLabel.text = placeholder
                hyperlink = nil
            case youtube:
                if let _url = URL(string: "https://www.youtube.com"),
                    UIApplication.shared.canOpenURL(_url) {
                    UIApplication.shared.open(_url, options: [:])
                }
            case wiki:
                if let _url = URL(string: "https://ru.m.wikipedia.org"),
                    UIApplication.shared.canOpenURL(_url) {
                    UIApplication.shared.open(_url, options: [:])
                }
            case instagram:
                if let _url = URL(string: "https://instagram.com"),
                    UIApplication.shared.canOpenURL(_url) {
                    UIApplication.shared.open(_url, options: [:])
                }
            case safari:
                if let _url = URL(string: "https://google.com"),
                    UIApplication.shared.canOpenURL(_url) {
                    UIApplication.shared.open(_url, options: [:])
                }
            default:
                print("default")
            }
        }
    }
}

extension HyperlinkSelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if !isAnimationStopped, let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon {
            let _anim = Animations.transformScale(fromValue: 1, toValue: 1.1, duration: 0.5, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self as CAAnimationDelegate)
            _anim.setValue(btn, forKey: "btn")
            btn.layer.add(_anim, forKey: nil)
            isAnimating = true
        }
    }
}
