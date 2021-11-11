//
//  UsersCollectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class UsersCollectionViewController: UICollectionViewController {

    internal let reuseIdentifier = "userCell"
    internal let itemsPerRow: CGFloat = 3
    internal let sectionInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
    internal var users: [UserProfile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "UserCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let user = users[indexPath.row] as? UserProfile, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? UserCell {
            cell.name.text   = user.name
            cell.gender.text = "\(user.gender.rawValue.lowercased()), \(user.age)"
            if let image = user.image {
                let circle = image.circularImage(size: cell.imageView.frame.size, frameColor: K_COLOR_RED)
                cell.imageView.image = circle
            } else {
                //Download
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

extension UsersCollectionViewController : UICollectionViewDelegateFlowLayout {
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
