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
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    var categories: [Topic]!
    fileprivate var parentMode = false
    var needsAnimation = true
//    fileprivate var effectView: AnimatedVisualEffectView!
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    weak var delegate: CallbackObservable?
    var currentIndex: IndexPath = IndexPath(row: 0, section: 0)
    var childColor: UIColor?
    var returnPos: CGPoint = .zero
    var selectionMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(UINib(nibName: "CategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        if categories == nil {
            parentMode = true
            categories = Topics.shared.all.filter { $0.parent == nil }.sorted { $0.totalCount > $1.totalCount }
        }
        effectView.frame = collectionView.bounds
        effectView.addEquallyTo(to: collectionView)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
            self.effectView.effect = nil
        }) {
            _ in
            self.effectView.alpha = 0
        }
        
//        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
//            // this is the main trick, animating between a blur effect and nil is how you can manipulate blur radius
//            self.effectView.effect = nil
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.backgroundColor = .white
        needsAnimation = true
//        effectView = AnimatedVisualEffectView(duration: 0.5, curve: .linear)//, effect: UIBlurEffect(style: .light))
//        effectView.beginAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) { self.effectView.effect = nil }
//        effectView.beginAnimator.startAnimation()
//        effectView.beginAnimator.pauseAnimation()
//        effectView.frame = collectionView.bounds
//        effectView.addEquallyTo(to: collectionView)
//        effectView.alpha = 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell {
            if let category = categories[indexPath.row] as? Topic {
                cell.childColor = childColor
                cell.category = category
                cell.total.alpha = selectionMode ? 0 : 1
                if selectionMode, (category.parent != nil || category.hasNoChildren) {
                    cell.selectionMode = true
                    cell.icon.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                }
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
//        if !parentMode && needsAnimation {
        if needsAnimation {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIView.animate(
//                withDuration: 0.6,
//                delay: (Double(arc4random_uniform(6)) * 0.01) * Double(arc4random_uniform(5)),//Double(indexPath.row),
//                usingSpringWithDamping: 0.6,
//                initialSpringVelocity: 1.1,
//                options: [.curveEaseOut],
//                animations: {
//                    cell.alpha = 1
//                    cell.transform = .identity
//            }) {
//                _ in
//                self.needsAnimation = (self.collectionView.visibleCells.count < (indexPath.row + 1))
//            }
            UIView.animate(
                withDuration: 0.2,
                delay: (Double(arc4random_uniform(6)) * 0.01) * Double(arc4random_uniform(5)),//Double(indexPath.row),
                options: [.curveEaseInOut],
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
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let category = cell.category, category.parent == nil, selectionMode  {
                if category.hasNoChildren {
                    //Subcategory
                    delegate?.callbackReceived(category)
                } else {
                    //Parent category
//                    let icon = SurveyCategoryIcon(frame: cell.icon.frame)
//                    icon.isOpaque = false
//                    icon.center = cell.convert(cell.icon.center, to: view)
//                    icon.tagColor = cell.icon.tagColor
//                    icon.categoryID = cell.icon.categoryID
//
//                    collectionView.addSubview(icon)
////                    cell.icon.alpha = 0
                    
//                    view.isUserInteractionEnabled = false
//                    self.effectView.alpha = 1
//                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.12, delay: 0, options: [.curveLinear], animations: {
//                        self.effectView.effect = UIBlurEffect(style: .prominent)
//                        self.collectionView.alpha = 0
//                    }) {
//                        _ in
                        DispatchQueue.main.async {
                            self.delegate?.callbackReceived(category)
                        }
//                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.19, delay: 0, options: [.curveLinear], animations: {
//                            self.effectView.effect = nil
//                            self.collectionView.alpha = 1
//                        }) {
//                            _ in
//                            self.effectView.alpha = 0
//                            self.view.isUserInteractionEnabled = true
//                        }
//                    }
                }
            } else {
                //Subcategory
                delegate?.callbackReceived(category)
            }
        } 
    }
    
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let category = cell.category, category.parent == nil {
//            if selectionMode {
//                let icon = SurveyCategoryIcon(frame: cell.icon.frame)
//                icon.isOpaque = false
//                icon.center = cell.convert(cell.icon.center, to: view)
//                icon.tagColor = cell.icon.tagColor
//                icon.categoryID = cell.icon.categoryID
//                collectionView.addSubview(icon)
//                cell.icon.alpha = 0
//                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
//                    icon.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
//                    icon.alpha = 0
//                }) {
//                    _ in
//                    icon.removeFromSuperview()
//                    cell.icon.alpha = 1
//                }
//            }
//            //                category.pointInParentView = cell.convert(cell.icon.center, to: view)
//        }
//        return true
//    }
    
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
