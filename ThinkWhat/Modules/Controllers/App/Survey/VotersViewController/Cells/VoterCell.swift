//
//  VoterCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoterCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private var user: Userprofile!
    private weak var delegate: CallbackObservable?
//    private var isViewSetupComplete = false
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var label: UILabel!
    
    public func setupUI(callbackDelegate: CallbackObservable?, userprofile: Userprofile, color: UIColor) {
//        guard !isViewSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        user = userprofile
        delegate = callbackDelegate
//        isViewSetupComplete = true
        setText()
        guard !avatar.isNil else { return }
        avatar.lightColor = color.withAlphaComponent(0.5)
        avatar.darkColor = color.withAlphaComponent(0.5)
        setImage()
    }
    
    private func setText() {
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(user.firstName), \(user.age)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: frame.height * 0.12), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        label.attributedText = attributedText
    }
    
    private func setImage() {
        if let image = user.image {
            avatar.setImage(image)
        } else {
            if let image = UIImage(named: "user") {
                avatar.setImage(image)
            }
            Task {
                do {
                    let image = try await user.downloadImageAsync()
                    await MainActor.run {
                        Animations.onImageLoaded(imageView: avatar.imageView, image: image)
                    }
                } catch {
#if DEBUG
                    print(error)
#endif
                }
            }
        }
    }
}
