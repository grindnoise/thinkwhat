//
//  AuthorCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class AuthorCell: UITableViewCell {
    private weak var delegate: CallbackObservable?
    private var survey: Survey!
    private var isSetupComplete = false
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var avatar: delAvatar! {
        didSet {
            avatar.backgroundColor = .clear
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.handleTap(recognizer:)))
            touch.cancelsTouchesInView = false
            avatar.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var stars: StarView! {
        didSet {
            stars.backgroundColor = .clear
        }
    }
    @IBOutlet weak var ratingLabel: UILabel! {
        didSet {
            ratingLabel.backgroundColor = .clear
        }
    }
    @IBOutlet weak var viewsIcon: Icon! {
        didSet {
            viewsIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
            viewsIcon.scaleMultiplicator = 1.4
            viewsIcon.backgroundColor = .clear
            viewsIcon.category = .Eye
        }
    }
    @IBOutlet weak var viewsLabel: UILabel! {
        didSet {
            viewsLabel.backgroundColor = .clear
        }
    }
    @IBOutlet weak var favoriteLabel: UILabel! {
        didSet {
            favoriteLabel.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var watchIcon: UIImageView! {
        didSet {
            watchIcon.backgroundColor = .clear
            watchIcon.image = ImageSigns.binocularsFilled.image
            watchIcon.contentMode = .scaleAspectFit
            watchIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        }
    }
    @IBOutlet weak var user: UILabel! {
        didSet {
            user.backgroundColor = .clear
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.callbackReceived(avatar as AnyObject)
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, survey _survey: Survey) {
        guard !isSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        delegate = callbackDelegate
        survey = _survey
        stars.color = survey.topic.tagColor
        avatar.lightColor = survey.isAnonymous ? .black : survey.topic.tagColor
        favoriteLabel.text = "\(survey.likes)"
        if survey.owner == Userprofile.anonymous {
            avatar.image = UIImage(named: "anon")!
        } else if let image = survey.owner.image {
            avatar.image = image
        } else {
            fatalError()
//            Task {
//                do {
//                    let data = try await survey.owner.downloadImageAsync()
//                    await MainActor.run { avatar.image = data}
//                } catch {}
//            }
        }
        let categoryString = NSMutableAttributedString()
//        categoryString.append(NSAttributedString(string: "\(survey.topic.localized.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .white : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//        categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .white : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//        categoryString.append(NSAttributedString(string: "\(survey.topic.parent!.localized.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .white : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topic.attributedText = categoryString
        user.text = survey!.owner.firstName
        var rating = min(Double(survey.votesTotal)*5/Double(survey.views), 5)//.rounded(toPlaces: 1)
        if rating < 0.5 {
            rating = 0
        }
        stars.rating = rating
        ratingLabel.text = String(format: "%.1f", rating)
        viewsLabel.text = "\(survey.views)"
        if survey.owner.lastName.count > 0 {
            user.text! += "\n\(survey.owner.lastName)"
        }
        isSetupComplete = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        watchIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        switch traitCollection.userInterfaceStyle {
        case .dark:
            let categoryString = NSMutableAttributedString()
//            categoryString.append(NSAttributedString(string: "\(survey!.topic.localized.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//            categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//            categoryString.append(NSAttributedString(string: "\(survey!.topic.parent!.localized.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            self.topic.attributedText = categoryString
            self.viewsIcon.setIconColor(.systemBlue)
        default:
            let categoryString = NSMutableAttributedString()
//            categoryString.append(NSAttributedString(string: "\(survey!.topic.localized.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//            categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//            categoryString.append(NSAttributedString(string: "\(survey!.topic.parent!.localized.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            self.topic.attributedText = categoryString
            self.viewsIcon.setIconColor(.black)
        }
    }
}
