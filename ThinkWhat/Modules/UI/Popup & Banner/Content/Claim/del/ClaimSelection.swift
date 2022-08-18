//
//  ClaimSelection.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ClaimSelection: UIView {
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    init(callbackDelegate _callbackDelegate: CallbackObservable) {
        super.init(frame: .zero)
        commonInit()
        callbackDelegate = _callbackDelegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor = .clear
        bounds = UIScreen.main.bounds
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            icon.setIconColor(.systemBlue)
            cancel.setTitleColor(.systemBlue, for: .normal)
            self.btn.backgroundColor = self.isEnabled ? .systemBlue : .darkGray
        default:
            icon.setIconColor(self.color)
            cancel.setTitleColor(.label, for: .normal)
            self.btn.backgroundColor = self.isEnabled ? self.color : K_COLOR_GRAY
        }
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "ClaimCell", bundle: nil), forCellReuseIdentifier: "claim")
        }
    }
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : K_COLOR_GRAY
            btn.accessibilityIdentifier = "exit"
            btn.setTitle("sendButton".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func btnTapped(_ sender: UIButton) {
        guard !choice.isNil else { return }
        callbackDelegate?.callbackReceived(choice)
        animate(sender)
    }
    @IBOutlet weak var cancel: UIButton! {
        didSet {
            cancel.setTitleColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label, for: .normal)
//            cancel.accessibilityIdentifier = "dismiss"
            cancel.setTitle("cancel".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func cancelTapped(_ sender: UIButton) {
        callbackDelegate?.callbackReceived(sender)
    }
    @IBOutlet weak var icon: Icon! {
        didSet {
            icon.backgroundColor = .clear
            icon.isRounded = false
            icon.scaleMultiplicator = 1.1
            icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            icon.category = .Caution
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            let textContent_1 = "claim_sent".localized + "\n" + "\n"
            let textContent_2 = "thanks_for_feedback".localized
            let paragraph = NSMutableParagraphStyle()
            
            if #available(iOS 15.0, *) {
                paragraph.usesDefaultHyphenation = true
            } else {
                paragraph.hyphenationFactor = 1
            }
            paragraph.alignment = .center
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: textContent_1,
                                                       attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 25), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
                                    
            attributedString.append(NSAttributedString(string: textContent_2,
                                                       attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 20), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            label.attributedText = attributedString
        }
    }
    
    override var frame: CGRect {
        didSet {
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
        }
    }
    override var bounds: CGRect {
        didSet {
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
        }
    }

    // MARK: - Properties
    private weak var callbackDelegate: CallbackObservable?
    private var isEnabled = false
    private var color = K_COLOR_RED
    private var choice: Claim! {
        didSet {
            if oldValue != choice {
                isEnabled = true
                //UI update
                enable()
                tableView.visibleCells.filter { ($0 as! _ClaimCell).claim != choice }.forEach { ($0 as! _ClaimCell).isChecked = false }
            }
        }
    }
    
    // MARK: - Methods
    private func enable() {
        UIView.animate(withDuration: 0.3, animations: {
            self.btn.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
        }) { _ in }
    }
    
    private func animate(_ sender: Optional<Any> = nil) {
        let pathAnim = Animations.get(property: .Path, fromValue: (self.icon.icon as! CAShapeLayer).path!, toValue: (self.icon.getLayer(.Letter) as! CAShapeLayer).path!, duration: 0.5, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
        self.icon.icon.add(pathAnim, forKey: nil)
        UIView.animate(withDuration: 0.15, animations: {
            self.btn.alpha = 0
            self.btn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { _ in }
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) {
            self.cancel.alpha = 0
            self.cancel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } completion: { _ in }
        
        UIView.animate(withDuration: 0.15, delay: 0.1, options: .curveLinear) {
            self.tableView.alpha = 0
            self.tableView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                self.label.transform = .identity
                self.label.alpha = 1
            } completion: { _ in
                delay(seconds: 1.25) {
                    self.callbackDelegate?.callbackReceived(sender as Any)
                }
            }
        }
    }
}

extension ClaimSelection: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Claims.shared.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "claim", for: indexPath) as? _ClaimCell, let claim = Claims.shared.all[indexPath.row] as? Claim {
            cell.setupUI(claim: claim, color: K_COLOR_RED)
            cell.isChecked = claim == choice
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? _ClaimCell {
            cell.isChecked = true
            choice = cell.claim
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView.frame.height / CGFloat(Claims.shared.all.count)
//    }
}

