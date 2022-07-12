//
//  VotersView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VotersView: UIView {
    
    deinit {
        print("VotersView deinit")
    }
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: VotersViewInput?
    private let reuseIdentifier = "voter"
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
//    private var needsAnimation = false
    private var requestAttempt = 0
    private var filtered: [Userprofile] = [] {
        didSet {
            collectionView.reloadData()
            viewInput?.setFilterEnabled(filtered.isEmpty ? false : filtered.count != answer.voters.count)
        }
    }
    private var filters: [String: AnyObject] = [:]
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
}

// MARK: - Controller Output
extension VotersView: VotersControllerOutput {
    func onDataLoaded(_ result: Result<[Userprofile], Error>) {
        switch result {
        case .success(let instances):
            instances.enumerated().forEach { (index, instance) in
                ///Add voter for an answer
                self.answer.addVoter(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
                self.collectionView.insertItems(at: [IndexPath(row: self.answer.voters.count - 1, section: 0)])
            }
        case .failure:
            showBanner(callbackDelegate: nil,
                       bannerDelegate: self, text: "voters_load_error".localized,
                       content: ImageSigns.exclamationMark,
                       color: .systemRed,
                       isModal: false,
                       dismissAfter: 1)
        }
    }
    
//    var indexPath: IndexPath {
//        return viewInput!.indexPath
//    }
    
    var answer: Answer {
        return viewInput!.answer
    }
    
    func onFilterTapped() {
        let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
        banner.accessibilityIdentifier = "claim"
        banner.present(content: VotersFilter(imageContent: ImageSigns.filterFilled, color: answer.survey?.topic.tagColor ?? K_COLOR_RED, callbackDelegate: banner, voters: answer.voters, filters: filters))
    }
}

// MARK: - UI Setup
extension VotersView {
    private func setupUI() {
        collectionView.register(UINib(nibName: "VoterCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
    }
}

extension VotersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.isEmpty ? answer.voters.count : filtered.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VoterCell {
            var userprofile: Userprofile!
            if filtered.isEmpty, let user = answer.voters[indexPath.row] as? Userprofile {
                userprofile = user
            } else if let user = filtered[indexPath.row] as? Userprofile {
                userprofile = user
            }
            
            guard !userprofile.isNil else { return UICollectionViewCell() }
            let color = viewInput?.color.withAlphaComponent(0.5) ?? K_COLOR_RED.withAlphaComponent(0.5)
            cell.setupUI(callbackDelegate: self, userprofile: userprofile, mode: .FirstnameAge, lightColor: color, darkColor: color)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //1 collectionView(_:layout:sizeForItemAt:) is responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension VotersView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        guard let dict = sender as? [String: AnyObject] else { return }
        if let _filtered = dict["filtered"] as? [Userprofile] {
            filtered = _filtered
        }
        if let _filters = dict["filters"] as? [String: AnyObject] {
            filters = _filters
        }
    }
}

extension VotersView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}


