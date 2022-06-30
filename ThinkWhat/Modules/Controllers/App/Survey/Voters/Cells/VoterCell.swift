//
//  VoterCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoterCell: UICollectionViewCell {

    enum CellMode {
        case FirstnameAge, FirstnameLastname
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var user: Userprofile!
    private weak var delegate: CallbackObservable?
    private var mode: CellMode!
    override var isSelected: Bool {
        didSet {
            checkmark.transform = oldValue == false ? CGAffineTransform(scaleX: 0.7, y: 0.7) : .identity
            checkmarkBg.transform = oldValue == false ? CGAffineTransform(scaleX: 0.7, y: 0.7) : .identity
            UIView.animate(withDuration: 0.1, delay: 0) {
                self.checkmark.alpha = self.isSelected ? 1 : 0
                self.checkmarkBg.alpha = self.isSelected ? 1 : 0
                self.checkmark.transform = self.isSelected ? .identity : CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.checkmarkBg.transform = self.isSelected ? .identity : CGAffineTransform(scaleX: 0.7, y: 0.7)
            }
        }
    }
    
//    override var frame: CGRect {
//        didSet {
//            guard !checkmark.isNil else { return }
//            checkmark.cornerRadius = checkmark.frame.height/2
//        }
//    }
//
//    override var bounds: CGRect {
//        didSet {
//            guard !checkmark.isNil else { return }
//            checkmark.cornerRadius = checkmark.bounds.height/2
//        }
//    }
//    private var isViewSetupComplete = false
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkmark: UIImageView! {
        didSet {
            checkmark.tintColor = .systemBlue
            checkmark.contentMode = .scaleAspectFit
            checkmark.image = ImageSigns.checkmarkFilled.image
            checkmark.layer.zPosition = 10
        }
    }
    @IBOutlet weak var checkmarkBg: UIView! {
        didSet {
            checkmarkBg.layer.zPosition = 9
        }
    }
    
    public func setupUI(callbackDelegate: CallbackObservable?, userprofile: Userprofile, mode _mode: CellMode, lightColor: UIColor, darkColor: UIColor = .systemBlue) {
//        guard !isViewSetupComplete else { return }
        self.mode = _mode
        setNeedsLayout()
        layoutIfNeeded()
        user = userprofile
        delegate = callbackDelegate
//        isViewSetupComplete = true
        setText()
        guard !avatar.isNil else { return }
        avatar.lightColor = lightColor//color.withAlphaComponent(0.5)
        avatar.darkColor = darkColor//color.withAlphaComponent(0.5)
        checkmarkBg.cornerRadius = checkmarkBg.bounds.height/2
        Task {
            do {
                let data = try await user.downloadImageAsync()
                await MainActor.run { avatar.image = data}
            } catch {}
        }
    }
    
    public func setSelectable(_ flag: Bool) {
        avatar.isUserInteractionEnabled = !flag
        label.isUserInteractionEnabled = !flag
    }
    
    private func setText() {
        let attributedText = NSMutableAttributedString()
        var text = ""
        var heightDivisor = 0.12
        switch mode {
        case .FirstnameAge:
            text = "\(user.firstNameSingleWord), \(user.age)"
        case .FirstnameLastname:
            text = "\(user.firstNameSingleWord)" + (!user.lastNameSingleWord.isEmpty ? "\n\(user.lastNameSingleWord)" : "")
            heightDivisor = 0.1
            label.numberOfLines = 2
        case .none:
#if DEBUG
            print("")
#endif
        }
        attributedText.append(NSAttributedString(string: text, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: frame.height * heightDivisor), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        label.attributedText = attributedText
    }
}
