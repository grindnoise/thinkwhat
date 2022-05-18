//
//  CurrentUserProfileView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CurrentUserProfileView: UIView {

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
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
    }
    
    private func setupUI() {
        setName()
    }
    
    private func setName() {
        guard let currentUser = Userprofiles.shared.current else { return }
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(currentUser.firstNameSingleWord)" + (!currentUser.lastNameSingleWord.isEmpty ? "\n\(currentUser.lastNameSingleWord)" : ""), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: name.frame.width * 0.11), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n\(currentUser.age), \(currentUser.gender.rawValue.localized.lowercased())" + (!currentUser.cityTitle.isNil ? ", \(currentUser.cityTitle!)" : ""), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: name.frame.width * 0.07), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        name.attributedText = attributedText
    }

    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatar: Avatar! {
        didSet {
            avatar.backgroundColor = .clear
//            avatar.darkColor = .clear
//            avatar.lightColor = .clear
            avatar.setImage(UIImage(named: "user")!)
        }
    }
    @IBOutlet weak var name: UILabel! {
        didSet {
            name.numberOfLines = 0
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    @IBOutlet weak var publications: UILabel!
    @IBOutlet weak var completed: UILabel!
    @IBOutlet weak var subscribers: UILabel!
    
}
