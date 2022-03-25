//
//  EmptySurvey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.05.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class EmptyCard: UIView {

    deinit {
        print("EmptySurvey deinit")
    }
    
    var startingPoint: CGPoint!
    var isEnabled = false
    weak fileprivate var delegate: CallbackDelegate?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var createButton: UIButton! {
        didSet {
            createButton.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .systemBlue
                default:
                    return K_COLOR_RED
                }
            }
        }
    }
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .secondarySystemBackground
                default:
                    return .systemBackground
                }
            }
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = "searching".localized.capitalized
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
    init(frame: CGRect, delegate _delegate: CallbackDelegate) {
        delegate = _delegate
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    private func setupUI() {
        createButton.layer.cornerRadius = createButton.frame.height/2.25
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.layer.shadowOpacity = 0
        default:
            self.layer.shadowOpacity = 1
        }
    }
    
    @objc fileprivate func callback(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.callbackReceived(self)
        }
    }
    
    func setEnabled(_ newValue: Bool, completion: @escaping(Bool)->()) {
        if newValue != isEnabled {
            isEnabled = newValue
            if isEnabled {
                loadingIndicator.addEnableAnimation()
                createButton.transform = createButton.transform.scaledBy(x: 0.75, y: 0.75)
                createButton.alpha = 0
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1
                }
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0.1,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 3,
                    options: [.curveEaseInOut],
                    animations: {
                        self.createButton.alpha = 1
                        self.createButton.transform = .identity
                }) { _ in completion(true) }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.createButton.transform = self.createButton.transform.scaledBy(x: 0.75, y: 0.75)
                    self.createButton.alpha = 0
                }) {
                    _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alpha = 0
                    }) {
                        _ in completion(true)
                    }
                }
            }
        } else {
            completion(true)
        }
    }

}
