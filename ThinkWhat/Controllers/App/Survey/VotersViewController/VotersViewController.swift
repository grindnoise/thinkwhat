//
//  VotersViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class VotersViewController: UIViewController {

    deinit {
        print("---\(self) deinit()")
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    let reuseIdentifier = "userCell"
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
    var frameColor: UIColor = K_COLOR_RED
    var surveyID: Int!
    var answer: Answer!
    var apiManager: APIManagerProtocol!
    var initialIndex: IndexPath!
    private var filterButton: Icon!
    private var needsAnimation = false
    private var requestAttempt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "UserCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        loadData()
        setupUI()
    }
    
    private func setupUI() {
        filterButton = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        filterButton.backgroundColor = .clear
        filterButton.iconColor = .lightGray
        filterButton.isRounded = false
        filterButton.category = .Filter
        let tap = UITapGestureRecognizer(target: self, action: #selector(VotersViewController.handleTap(recognizer:)))
        filterButton.addGestureRecognizer(tap)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterButton)]
        setTitle()
    }

    private func setTitle() {
        let navTitle = UILabel()
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: "Проголосовали", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: "\n\(answer.totalVotes)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 10), foregroundColor: .darkGray, backgroundColor: .clear)))
        navTitle.attributedText = attrString
        navigationItem.titleView = navTitle
    }
    
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, recognizer.view == filterButton {
            let anim = Animations.get(property: .FillColor, fromValue: filterButton.iconColor.cgColor, toValue: K_COLOR_RED.cgColor, duration: 0.3, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
            AlertController.shared.icon.category = .Filter
            AlertController.shared.show(delegate: self, height: UIScreen.main.bounds.height * 0.5, contentType: .Filter)
            
            filterButton.layer.add(anim, forKey: nil)
            (filterButton.icon as! CAShapeLayer).fillColor = K_COLOR_RED.cgColor
        }
    }
    
    private func loadData() {
        self.requestAttempt += 1
        apiManager.getVoters(surveyID: surveyID, answerID: answer.ID, userprofiles: answer.userprofiles.compactMap({ $0.ID })) {
            json, error in
            if error != nil {
                if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
                    Banner.shared.contentType = .Warning
                    if let content = Banner.shared.content as? Warning {
                        content.level = .Error
                        content.text = "Произошла ошибка, повторите попытку позже"
                    }
                    Banner.shared.present(shouldDismissAfter: 2, delegate: nil)
                    self.requestAttempt = 0
                } else {
                    //Retry
                    self.loadData()
                }
            }
            if json != nil {
                if let _userprofiles = json!["userprofiles"].arrayValue as? [JSON] {
                    for (i, _userprofile) in _userprofiles.enumerated() {
                        var userprofile: UserProfile!
                        if let ID = _userprofile["id"].intValue as? Int, let foundValue = UserProfiles.shared.container.filter({ $0.ID == ID }).first {
                            userprofile = foundValue
                        } else if let newUserprofile = UserProfile(_userprofile) {
                            UserProfiles.shared.container.append(newUserprofile)
                            userprofile = newUserprofile
                        }
                        self.answer.appendUserprofile(userprofile)
                        self.needsAnimation = true
                        self.collectionView.insertItems(at: [IndexPath(row: self.answer.userprofiles.count - 1, section: 0)])
                        //                        self.collectionView.reloadItems(at: [IndexPath(row: self.answer.userprofiles.count - 1, section: 0)])
                        if i == _userprofiles.count - 1 {
                            delay(seconds: 0.5) {
                                self.needsAnimation = false
                            }
                        }
                    }
                }
                self.requestAttempt = 0
            }
        }
    }
}

extension VotersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answer.userprofiles.count//users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let user = answer.userprofiles[indexPath.row] as? UserProfile, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? UserCell {
            cell.name.text   = user.name
            cell.age = user.age
            cell.gender = user.gender
            if let image = user.image {
                let circle = image.circularImage(size: cell.imageView.frame.size, frameColor: frameColor)
                cell.imageView.image = circle
            } else if let url = answer.userprofiles[indexPath.row].imageURL as? String, !url.isEmpty {
                let circle = UIImage(named: "user")!.circularImage(size: cell.imageView.frame.size, frameColor: frameColor)
                cell.imageView.image = circle
                //Download
                apiManager.downloadImage(url: url) {
                    image, error in
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                    if image != nil {
                        UIView.transition(with: cell.imageView,
                                          duration: 0.5,
                                          options: .transitionCrossDissolve,
                                          animations: { cell.imageView.image = image!.circularImage(size: cell.imageView.frame.size, frameColor: self.frameColor) }
                        ) {
                            _ in
                            self.answer.userprofiles[indexPath.row].image = image
                        }
                    }
                }
            } else {
                let circle = UIImage(named: "user")!.circularImage(size: cell.imageView.frame.size, frameColor: frameColor)
                cell.imageView.image = circle
            }
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
        let availableWidth = view.frame.width - paddingSpace
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

extension VotersViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        print(sender)
    }
}
