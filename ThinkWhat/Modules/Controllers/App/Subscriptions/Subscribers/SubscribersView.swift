//
//  SubscribersView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubscribersView: UIView {
    
    deinit {
        print("SubscribersView deinit")
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
    weak var viewInput: SubscribersViewInput?
    private var _unsubscribeList: [IndexPath: Userprofile] = [:]
    private let reuseIdentifier = "voter"
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
//    private var needsAnimation = false
    private var requestAttempt = 0
    private var isEditingEnabled = false {
        didSet {
            guard !collectionView.isNil else { return }
            collectionView.allowsSelection = isEditingEnabled
            collectionView.allowsMultipleSelection = isEditingEnabled
            collectionView.visibleCells.forEach {
                if let cell = $0 as? VoterCell {
                    cell.setSelectable(isEditingEnabled)
                }
            }
        }
    }
    
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
extension SubscribersView: SubscribersControllerOutput {
    func onSubscribedForUpdated() {
        collectionView.reloadData()
    }
    
    func onAPIError() {
        showBanner(callbackDelegate: nil, bannerDelegate: self, text: AppError.server.localizedDescription, imageContent: ImageSigns.exclamationMark)
    }
    
    var unsubscribeList: [Userprofile] {
        return _unsubscribeList.enumerated().map { dict in
            return dict.element.value
        }
    }
    
    
    func onDataLoaded(_ result: Result<[Userprofile], Error>) {
        switch result {
        case .success(let instances):
            instances.enumerated().forEach { (index, instance) in
                ///Add voter for an answer
                Userprofiles.shared.addSubscriber(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
                self.collectionView.insertItems(at: [IndexPath(row: Userprofiles.shared.subscribers.count - 1, section: 0)])
            }
        case .failure:
            showBanner(callbackDelegate: nil,
                       bannerDelegate: self, text: "voters_load_error".localized,
                       imageContent: ImageSigns.exclamationMark,
                       color: .systemRed,
                       isModal: false,
                       shouldDismissAfter: 1)
        }
    }
    
    func enableEditing() {
        isEditingEnabled = true
    }
    
    func disableEditing() {
        isEditingEnabled = false
        _unsubscribeList.removeAll()
    }
}

// MARK: - UI Setup
extension SubscribersView {
    private func setupUI() {
        collectionView.register(UINib(nibName: "VoterCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
    }
}

extension SubscribersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewInput?.userprofiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VoterCell, let userprofile = viewInput?.userprofiles[indexPath.row] as? Userprofile {
            cell.setupUI(callbackDelegate: self, userprofile: userprofile, mode: .FirstnameLastname, lightColor: K_COLOR_RED)
            cell.setSelectable(isEditingEnabled)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard isEditingEnabled else { return false}
        guard let cell = collectionView.cellForItem(at: indexPath) as? VoterCell, !cell.isSelected else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return false
        }
        return true
//        guard let cell = collectionView.cellForItem(at: indexPath) as? VoterCell else { return }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VoterCell else { return }
        _unsubscribeList[indexPath] = cell.user
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard isEditingEnabled else { return false}
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        _unsubscribeList.removeValue(forKey: indexPath)
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

extension SubscribersView: CallbackObservable {
    func callbackReceived(_ sender: Any) {

    }
}

extension SubscribersView: BannerObservable {
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

