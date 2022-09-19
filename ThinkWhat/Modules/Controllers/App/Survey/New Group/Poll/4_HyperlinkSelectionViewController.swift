////
////  HyperlinkSelectionViewController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 24.12.2020.
////  Copyright © 2020 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//import SafariServices
//
//class HyperlinkSelectionViewController: UIViewController {
//    
//    deinit {
//        print("***HyperlinkSelectionViewController deinit***")
//    }
//
//    @IBOutlet weak var hyperlinkLabel: InsetLabel! {
//        didSet {
//            hyperlinkLabel.font = font
//            hyperlinkLabel.textColor = textColor
//            hyperlinkLabel.tintColor = textColor
//            hyperlinkLabel.backgroundColor = .clear
//            if let str = hyperlink?.absoluteString {
//                hyperlinkLabel.text = str
//            } else {
//                hyperlinkLabel.attributedText = placeholder
//            }
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            hyperlinkLabel.addGestureRecognizer(tap)
//        }
//    }
////    @IBOutlet weak var trashHeightConstraint: NSLayoutConstraint!
////    private var trashHeightConstraintNew: NSLayoutConstraint!
////    private var trashHeight: CGFloat = 0
//    //    @IBOutlet weak var trashIconConstaint: NSLayoutConstraint!
//    
//    //    private var placeholder = NSAttributedString(string: "http://...", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 20), foregroundColor: UIColor.lightGray, backgroundColor: .clear))
//    var isAnimationStopped = false
//    lazy var placeholder: NSMutableAttributedString = {
//        let attrString = NSMutableAttributedString()
//        attrString.append(NSAttributedString(string: "Вставить ссылку", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 18), foregroundColor: .darkGray, backgroundColor: .clear)))
////        attrString.append(NSAttributedString(string: "\n(опционально)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: .lightGray, backgroundColor: .clear)))
//        return attrString
//    }()
//    var font: UIFont?
//    var textColor: UIColor?
//    var hyperlink: URL? {
//        didSet {
//            if actionButton != nil, trashSign != nil {
//                if hyperlink == nil {
//                    UIView.animate(withDuration: 0.2) {
//                        //                    self.copySign.alpha = 1
//                        self.trashSign.alpha = 0
//                    }
//                    if actionButton != nil {
//                        //                    actionButton.isUserInteractionEnabled = false
////                            actionButton.color = K_COLOR_GRAY
//                        actionButton.icon.textSize = 26
//                        actionButton.text = "ПРОПУСТИТЬ"
//                    }
//                } else {
//                    UIView.animate(withDuration: 0.2) {
//                        //                    self.copySign.alpha = 0
//                        self.trashSign.alpha = 1
//                    }
//                    actionButton.color = K_COLOR_RED
//                    actionButton.icon.textSize = 43
//                    actionButton.text = "OK"
//                }
//            }
//        }
//    }
//    private var isViewSetupCompleted = false
//    var _labelHeight: CGFloat = 0
//    var color: UIColor!
//    var lineWidth: CGFloat = 5 {
//        didSet {
//            if oldValue != lineWidth, actionButton != nil {
//                actionButton.lineWidth = lineWidth
//            }
//        }
//    }
//    @IBOutlet weak var actionButton: CircleButton! {
//        didSet {
////            actionButton.isUserInteractionEnabled = hyperlink == nil ? false : true
//            actionButton.lineWidth = lineWidth
//            actionButton.state = .Off
//            actionButton.category = .Skip_RU
//            actionButton.color = hyperlink == nil ? K_COLOR_GRAY : K_COLOR_RED
//            actionButton.text = hyperlink == nil ? "ПРОПУСТИТЬ" : "OK"
//            actionButton.icon.textSize = hyperlink == nil ? 26 : 43
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            actionButton.addGestureRecognizer(tap)
//        }
//    }
////    @IBAction func dismiss(_ sender: Any) {
////        navigationController?.popViewController(animated: true)
////    }
////    @IBOutlet weak var hyperlinkLabel: UnderlinedTextField! {
////        didSet {
////            if let str = hyperlink?.absoluteString {
////                hyperlinkLabel.text = str
////            } else {
////                hyperlinkLabel.attributedText = placeholder
////            }
////        }
////    }
////    @IBOutlet weak var labelHeight: NSLayoutConstraint! {
////        didSet {
////            labelHeight.constant = _labelHeight
////            hyperlinkLabel.setNeedsLayout()
////            hyperlinkLabel.layoutIfNeeded()
////        }
////    }
////    @IBOutlet weak var rightSpacing: NSLayoutConstraint! {
////        didSet {
////            rightSpacing.constant = _labelHeight / 4
////        }
////    }
////    @IBOutlet weak var copySign: CopyPasteIcon! {
////        didSet {
////            copySign.alpha = hyperlink == nil ? 1 : 0
////            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
////            copySign.addGestureRecognizer(tap)
////        }
////    }
//    
//    @IBOutlet weak var circle_1: UIView!
//    @IBOutlet weak var circle_2: UIView!
//    @IBOutlet weak var circle_3: UIView!
//    @IBOutlet weak var circle_4: UIView!
//    
//    @IBOutlet weak var trashSign: TrashIcon! {
//        didSet {
////            trashSign.alpha = hyperlink == nil ? 0 : 1
////            trashSign.color = color
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            trashSign.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var youtube: YoutubeLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            youtube.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var wiki: WikiLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            wiki.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var instagram: InstagramLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            instagram.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var safari: SafariLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.somethingTapped))
//            safari.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var contentView: UIView! {
//        didSet {
//            contentView.backgroundColor = color
//        }
//    }
//    @IBOutlet weak var stackView: UIStackView! {
//        didSet {
//            stackView.alpha = 0
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.isShadowed = false
//            nc.duration = 0.5
//            nc.transitionStyle = .Icon
//        }
//        navigationItem.setHidesBackButton(true, animated: false)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        lineWidth = actionButton.bounds.height / 10
//        if !isViewSetupCompleted {
//            view.setNeedsLayout()
//            view.layoutIfNeeded()
//            circle_1.cornerRadius = circle_1.frame.width / 2
//            circle_2.cornerRadius = circle_1.frame.width / 2
//            circle_3.cornerRadius = circle_1.frame.width / 2
//            circle_4.cornerRadius = circle_1.frame.width / 2
//            isViewSetupCompleted = true
//            if hyperlink != nil {
//                delay(seconds: 0.75) {
//                    self.actionButton.bounce(animationDelegate: self)
//                }
//            }
////            trashHeight = trashSign.frame.height
////            trashHeightConstraintNew = trashSign.heightAnchor.constraint(equalToConstant: trashHeight)
////            trashHeightConstraintNew.isActive = true
////            trashHeightConstraint.isActive = false
//            if hyperlink == nil {
//                trashSign.alpha = 0
//                hyperlinkLabel.attributedText = placeholder//NSAttributedString(string: hyperlink!.absoluteString, attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 20), foregroundColor: .darkGray, backgroundColor: .clear))
////                trashSign.setNeedsDisplay()
////                trashHeightConstraintNew.constant = 0
//            } else {
//                hyperlinkLabel.numberOfLines = 2
//                hyperlinkLabel.attributedText = NSAttributedString(string: hyperlink!.absoluteString, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .blue, backgroundColor: .clear))
//            }
//        }
//    }
//    
//    @objc fileprivate func somethingTapped(recognizer: UITapGestureRecognizer) {
//        
//        if let v = recognizer.view {
//            switch v {
//            case actionButton:
//                isAnimationStopped = true
//                if hyperlink == nil {
//                    navigationController?.popViewController(animated: true)
//                } else {
//                    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
//                        self.actionButton.transform = .identity
//                    }) {
//                        _ in
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//                
//            case hyperlinkLabel:
//                
//                if hyperlink == nil {
//                    if let text = UIPasteboard.general.string, !text.isEmpty {
//                        
//                        if let url = URL(string: text) {
//                            
//                            self.view.setNeedsLayout()
//                            //                        self.trashHeightConstraintNew.constant = self.trashHeight
//                            
//                            UIView.transition(with: hyperlinkLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                                self.hyperlinkLabel.numberOfLines = 2
//                                self.hyperlinkLabel.attributedText =  NSAttributedString(string: text, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .blue, backgroundColor: .clear))
//                            })
//                            
//                            self.trashSign.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//                            self.trashSign.alpha = 0
//                            
//                            UIView.animate(withDuration: 0.2, animations: {
//                                self.trashSign.transform = .identity
//                                self.trashSign.alpha = 1
//                            })
//                            
//                            isAnimationStopped = false
//                                actionButton.animateIconChange(toCategory: Icon.Category.Skip_RU)
//                                UIView.animate(withDuration: 0.15, animations: {
//                                    self.actionButton.color = K_COLOR_RED
//                                }) {
//                                    _ in
//                                    self.actionButton.bounce(animationDelegate: self)
//                                }
//                            hyperlink = url
//                        }
//                    }
//                    
//                } else {
//                    
//                    var vc: SFSafariViewController!
//                    if #available(iOS 11.0, *) {
//                        let config = SFSafariViewController.Configuration()
//                        config.entersReaderIfAvailable = true
//                        vc = SFSafariViewController(url: hyperlink!, configuration: config)
//                    } else {
//                        vc = SFSafariViewController(url: hyperlink!)
//                    }
//                    present(vc, animated: true)
//                    
//                }
//                
//            case trashSign:
//                
////                self.view.setNeedsLayout()
////                self.trashHeightConstraintNew.constant = 0
//                
//                UIView.transition(with: hyperlinkLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                    self.hyperlinkLabel.numberOfLines = 1
//                    self.hyperlinkLabel.attributedText = self.placeholder
//                })
//                
//                
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.trashSign.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//                    self.trashSign.alpha = 0
//                }) {
//                    _ in
//                    self.trashSign.transform = .identity
//                }
//                
//                actionButton.animateIconChange(toCategory: Icon.Category.Next_RU)
//                
//                isAnimationStopped = true
//                hyperlink = nil
//                
//            case youtube:
//                if let _url = URL(string: "https://www.youtube.com"),
//                    UIApplication.shared.canOpenURL(_url) {
//                    UIApplication.shared.open(_url, options: [:])
//                }
//            case wiki:
//                if let _url = URL(string: "https://ru.m.wikipedia.org"),
//                    UIApplication.shared.canOpenURL(_url) {
//                    UIApplication.shared.open(_url, options: [:])
//                }
//            case instagram:
//                if let _url = URL(string: "https://instagram.com"),
//                    UIApplication.shared.canOpenURL(_url) {
//                    UIApplication.shared.open(_url, options: [:])
//                }
//            case safari:
//                if let _url = URL(string: "https://google.com"),
//                    UIApplication.shared.canOpenURL(_url) {
//                    UIApplication.shared.open(_url, options: [:])
//                }
//            default:
//                print("default")
//            }
//        }
//    }
//}
//
//extension HyperlinkSelectionViewController: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if !isAnimationStopped {
//            actionButton.layer.removeAllAnimations()
//            actionButton.bounce(animationDelegate: self)
//        } else {
//            actionButton.scaleColorAnim = nil
//            UIView.animate(withDuration: 0.15) {
//                self.actionButton.icon.backgroundColor = K_COLOR_GRAY
//            }
//        }
////        if !isAnimationStopped {
////            actionButton.bounce(animationDelegate: self)
////        } else {
////            UIView.animate(withDuration: 0.15) {
////                self.actionButton.icon.backgroundColor = K_COLOR_GRAY
////            }
////        }
//    }
//}
