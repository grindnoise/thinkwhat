//
//  CategoryCollectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController {

    let reuseIdentifier = "category"
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var categories: [SurveyCategory]!
    fileprivate var parentMode = false
    fileprivate var needsAnimation = true
    weak var delegate: CallbackDelegate?
    var currentIndex: IndexPath = IndexPath(row: 0, section: 0)
    var childColor: UIColor?
    var returnPos: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(UINib(nibName: "CategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        if categories == nil {
            parentMode = true
            categories = SurveyCategories.shared.categories.filter { $0.parent == nil }.sorted { $0.total > $1.total }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.backgroundColor = .white
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell {
            if let category = categories[indexPath.row] as? SurveyCategory {
                cell.childColor = childColor
                cell.category = category
            }
//            if parentMode {
//                cell.layer.cornerRadius = cell.frame.width / 8
//                cell.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//                cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.frame.width / 8).cgPath//(rect: cell.bounds).cgPath
//                cell.layer.shadowRadius = 4
//                cell.layer.shadowOffset = .zero
//                cell.layer.shadowOpacity = 1
//            }

            return cell
        }
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !parentMode && needsAnimation {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(
                withDuration: 0.6,
                delay: (Double(arc4random_uniform(7)) * 0.01) * Double(arc4random_uniform(9)),//Double(indexPath.row),
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 1.1,
                options: [.curveEaseOut],
                animations: {
                    cell.alpha = 1
                    cell.transform = .identity
            }) {
                _ in
                self.needsAnimation = (self.collectionView.visibleCells.count < (indexPath.row + 1))
            }
            //UIView.animate(withDuration: 0.3, delay: 0.06 * Double(indexPath.row), options: [], animations: { cell.alpha = 1 })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let category = cell.category {
            currentIndex = indexPath
            delegate?.callbackReceived(category)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            delegate?.callbackReceived(["isShadowed": false] as AnyObject)
        } else if scrollView.contentOffset.y > 0 {
            delegate?.callbackReceived(["isShadowed": true] as AnyObject)
        }
    }
}

extension CategoryCollectionViewController : UICollectionViewDelegateFlowLayout {
    //1 collectionView(_:layout:sizeForItemAt:) is responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
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
