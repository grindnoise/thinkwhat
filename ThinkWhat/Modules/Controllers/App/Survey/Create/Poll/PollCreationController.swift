//
//  PollCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices

class PollCreationController: UIViewController {

    deinit {
        controllerOutput?.onDeinit()
        print("PollCreationController deinit")
    }

    //Sequence of stages to post new survey
    enum Stage: Int, CaseIterable {
        case Topic, Options, Title, Description, Question, Hyperlink, Images, Choices, Comments, Limits, Hot, Ready
        
        func next() -> Stage? {
            return Stage(rawValue: (self.rawValue + 1))
        }
    }
    
    enum Option: String {
        case Null = "", Ordinary = "default_option", Anon = "anon_option", Private = "private_option"
    }
    
    enum Comments {
        case On, Off
    }
    
    enum Hot {
        case On, Off
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let model = PollCreationModel()
               
        self.controllerOutput = view as? PollCreationView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        title = "new_poll".localized
        navigationItem.largeTitleDisplayMode = .always
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.navigationBar.sizeToFit()
//        }
//        let navigationBar = navigationController?.navigationBar
//        let navigationBarAppearance = UINavigationBarAppearance()
//        navigationBarAppearance.shadowColor = .systemGray
//        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        progressIndicator.clipsToBounds = false
        progressIndicator.layers.forEach{ $0.value.masksToBounds = false }
        progressIndicator.subviews.forEach{ $0.layer.masksToBounds = false }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard stage == .Topic else { return }
        controllerOutput?.onNextStage(.Topic)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        ///User refused to accept terms & conditions -> log out
//        if isMovingToParent {
////            UIView.animate(withDuration: 0.15, delay: 0) {
////                self.progressIndicator.alpha = 0
////                self.progressIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
////            } completion: { _ in
//
////            }
//        }
//    }
    
    override func willMove(toParent parent: UIViewController?) {
        willMoveToParent = parent.isNil ? true : false
        super.willMove(toParent: parent)
        self.progressIndicator.removeFromSuperview()
    }
    
    private func setupUI() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(progressIndicator)
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressIndicator.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState*2),
            progressIndicator.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0),// -UINavigationController.Constants.ImageBottomMarginForSmallState),
            progressIndicator.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState*3.5),
            progressIndicator.widthAnchor.constraint(equalTo: progressIndicator.heightAnchor, multiplier: 1.0/1.0)
            ])
        progressIndicator.layer.masksToBounds = false
        progressIndicator.lineWidth = progressIndicator.frame.width * 0.1
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        progressIndicator.icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : stage == .Ready ? .systemGreen : K_COLOR_RED)
        progressIndicator.oval.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor
        animateProgress(false)
    }
    
    private func animateProgress(_ animated: Bool = true) {
        let total = Stage.allCases.count - 1
        let current = stage.rawValue
        
        let percentage = current * 100 / total
        let strokeStart = CGFloat(1.0 - Double(percentage) / 100.0)
        
        //1 -> 0
        if animated {
        let anim = Animations.get(property: .StrokeStart, fromValue: progressIndicator.oval.strokeStart, toValue: strokeStart, duration: 0.3, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: true, completionBlocks: [])
        progressIndicator.oval.add(anim, forKey: nil)
        }
        self.progressIndicator.oval.strokeStart = strokeStart
        if animated {
        let scaleAnim = Animations.get(property: .Scale, fromValue: 1.0, toValue: 1.05, duration: 0.15, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut, delegate: nil, isRemovedOnCompletion: true, completionBlocks: [])
        progressIndicator.layer.add(scaleAnim, forKey: nil)
        }
    }
    
    // MARK: - Properties
    var controllerOutput: PollCreationControllerOutput?
    var controllerInput: PollCreationControllerInput?
    var stage: Stage = .Topic {
        didSet {
            guard oldValue != stage else { return }
            if stage == .Ready {
                let strokeAnim = Animations.get(property: .StrokeStart, fromValue: progressIndicator.oval.strokeStart, toValue: 1, duration: 0.4, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: true, completionBlocks: [{
                }])
                progressIndicator.oval.add(strokeAnim, forKey: nil)
                progressIndicator.oval.strokeStart = 1
                
                let strokeColorAnim = Animations.get(property: .StrokeColor, fromValue: progressIndicator.oval.strokeColor as Any, toValue: UIColor.clear.cgColor, duration: 0.5, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: true, completionBlocks: [])
                progressIndicator.oval.add(strokeColorAnim, forKey: nil)
                progressIndicator.oval.opacity = 0
                
                guard let icon = self.progressIndicator.icon.icon as? CAShapeLayer else { return }
                let color = self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : UIColor.systemGreen
                
                let fillColorAnim = Animations.get(property: .StrokeColor, fromValue: icon.fillColor as Any, toValue: color.cgColor, duration: 0.5, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: true, completionBlocks: [])
                icon.add(fillColorAnim, forKey: nil)
                icon.fillColor = color.cgColor
                
                let destinationPath = (self.progressIndicator.icon.getLayer(.Checkmark) as! CAShapeLayer).path!
                let pathAnim = Animations.get(property: .Path, fromValue: icon.path!, toValue: destinationPath, duration: 0.4, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: true)
                icon.add(pathAnim, forKey: nil)
                icon.path = destinationPath
            } else {
                animateProgress()
            }
        }
    }

    private lazy var progressIndicator: CircleButton = {
        let customTitle = CircleButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)), useAutoLayout: true)
        customTitle.color = .white
        customTitle.icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        customTitle.icon.backgroundColor = .clear
        customTitle.layer.masksToBounds = false
        customTitle.icon.layer.masksToBounds = false
        customTitle.oval.masksToBounds = false
        customTitle.icon.scaleMultiplicator = 1.7
        customTitle.category = .Poll
        customTitle.state = .Off
        customTitle.contentView.backgroundColor = .clear
        customTitle.oval.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor
        customTitle.oval.lineCap = .round
        return customTitle
    }()
    var willMoveToParent = false
}

// MARK: - View Input
extension PollCreationController: PollCreationViewInput {
    func post(_ dict: [String: Any]) {
        controllerInput?.post(dict)
    }
    
    var balance: Int {
        return controllerInput?.balance ?? 0
    }
    
    func onURLTapped(_ url: URL?) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url ?? URL(string: "https://google.com")!, configuration: config)
        present(vc, animated: true)
    }
    
    func onStageCompleted() {
        guard let next = stage.next() else { return }
        stage = next
        Task {
            await MainActor.run {
                controllerOutput?.onNextStage(stage)
            }
        }
    }
}

extension PollCreationController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
            initialLayer.path = path as! CGPath
            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
                completionBlock()
            }
        }
    }
}

// MARK: - Model Output
extension PollCreationController: PollCreationModelOutput {
    func onContinue() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func onSuccess() {
        controllerOutput?.onSuccess()
    }
    
    func onError(_ error: Error) {
        controllerOutput?.onError(error)
    }
}

extension UIColor {

    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
