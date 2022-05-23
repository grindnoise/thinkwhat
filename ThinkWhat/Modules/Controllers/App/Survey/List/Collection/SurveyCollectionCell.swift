//
//  SurveyCollectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class SurveyCollectionCell: UICollectionViewListCell {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: SurveyReference! {
        didSet {
            guard item.owner.image.isNil else { return }
            Task {
                do {
                    try await item.owner.downloadImageAsync()
                    await MainActor.run {
                        updateConfiguration(using: .init(traitCollection: UITraitCollection.current))
                    }
                } catch {
#if DEBUG
                    print(error)
#endif
                }
            }
        }
    }
    
    private func setObservers() {
        let names = [Notifications.Surveys.Completed,
                     Notifications.Surveys.Views,
//                     Notifications.Surveys.UpdateFavorite,
                     Notifications.Surveys.UnsetFavorite,
                     Notifications.Surveys.SetFavorite,
                     Notifications.Surveys.UpdateHotSurveys]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.forceUpdate), name: $0, object: nil) }
    }
    
    @objc
    private func forceUpdate() {
        updateConfiguration(using: .init(traitCollection: UITraitCollection.current))
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundColor = .clear
        var newConfiguration = SurveyCollectionCellConfiguration().updated(for: state)
        newConfiguration.title = item.title
        newConfiguration.titleTopic = item.topic.title
        newConfiguration.titleTopicParent = item.topic.parent!.title
        newConfiguration.icon = Icon.Category(rawValue: item.topic.id) ?? .Null
        newConfiguration.avatar = item.owner == Userprofiles.shared.anonymous ? UIImage(named: "anon") : item.owner.image 
        newConfiguration.isComplete = item.isComplete
        newConfiguration.progress = item.progress
        newConfiguration.views = item.views
        newConfiguration.votesLimit = item?.votesLimit
        newConfiguration.color = item.topic.tagColor
        newConfiguration.firstName = item.owner.firstNameSingleWord
        newConfiguration.lastName = item.owner.lastNameSingleWord
        newConfiguration.isFavorite = item.isFavorite
        newConfiguration.isAnonymous = item.isAnonymous
        newConfiguration.isHot = item.isHot
        
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
struct SurveyCollectionCellConfiguration: UIContentConfiguration, Hashable {

    var firstName: String!
    var lastName: String!
    var title: String!
    var titleTopic: String!
    var titleTopicParent: String!
    var icon: Icon.Category!
    var avatar: UIImage?
    var isComplete: Bool!
    var views: Int!
    var votesLimit: Int!
    var color: UIColor!
    var progress: Int!
    var isFavorite: Bool!
    var isHot: Bool!
    var isAnonymous: Bool!
    
    func makeContentView() -> UIView & UIContentView {
        return SurveyCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else {
                return self
            }
        var updatedConfiguration = self
        return updatedConfiguration
    }
}
