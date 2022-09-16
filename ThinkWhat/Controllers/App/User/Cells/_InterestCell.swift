////
////  InterestCell.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 01.12.2021.
////  Copyright © 2021 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class InterestCell: UITableViewCell {
//    weak var userprofile: Userprofile?
//    var isViewSetupComplete = false
//    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
//        didSet {
//            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
////            collectionViewLayout.minimumInteritemSpacing = 5
//        }
//    }
////    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var collectionView: UICollectionView! {
//        didSet {
//            collectionView.register(UINib(nibName: "InterestCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "category")
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            columnLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//            collectionView.collectionViewLayout = columnLayout
////            collectionView.translatesAutoresizingMaskIntoConstraints = true
//        }
//    }
//    
//    let columnLayout = CustomViewFlowLayout()
//    private let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
//    private let itemsPerRow: CGFloat = 3
//    
//    override func layoutSubviews() {
//        if collectionView.contentSize == .zero {
//            collectionView.setNeedsLayout()
//            collectionView.layoutIfNeeded()
//            frame = CGRect(origin: frame.origin, size: collectionView.contentSize)
//        }
////        collectionView.superview?.heightAnchor.constraint(equalToConstant: collectionView.contentSize.height).isActive = true
////        collectionViewHeightConstraint.constant = collectionView.contentSize.height
//        collectionView.heightAnchor.constraint(equalToConstant: collectionView.contentSize.height).isActive = true
//        super.layoutSubviews()
////        }
//    }
////    override func updateConstraints() {
////        collectionView.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            collectionView.topAnchor.constraint(equalTo: bottomAnchor),
////            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
////            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
////            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
////        ])
////        super.updateConstraints()
////    }
////    override func awakeFromNib() {
////         super.awakeFromNib()
////
////         contentView.translatesAutoresizingMaskIntoConstraints = false
////
////         NSLayoutConstraint.activate([
////             contentView.leftAnchor.constraint(equalTo: leftAnchor),
////             contentView.rightAnchor.constraint(equalTo: rightAnchor),
////             contentView.topAnchor.constraint(equalTo: topAnchor),
////             contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
////         ])
////     }
//
//}
//
//extension InterestCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return userprofile?.topPublicationCategories?.count ?? 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as? InterestCollectionCell, let strongUserprofile = userprofile, let categories = strongUserprofile.sortedTopPublicationCategories {
//            if let dict = categories[indexPath.row] as? [Topic: Int], let category = dict.first?.key {
//                let attrString = NSMutableAttributedString()
//                attrString.append(NSAttributedString(string: category.title.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: UIScreen.main.bounds.width * 0.004), foregroundColor: .white, backgroundColor: .clear)))
//                attrString.append(NSAttributedString(string: "/", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: UIScreen.main.bounds.width * 0.004), foregroundColor: .white, backgroundColor: .clear)))
//                attrString.append(NSAttributedString(string: category.parent!.title.uppercased(),
//                                                     attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: UIScreen.main.bounds.width * 0.004), foregroundColor: .white, backgroundColor: .clear)))
//                
//                cell.categoryLabel.attributedText = attrString
////                cell.categoryLabel.text = category.title.lowercased()//" \(category.title.lowercased()) "
//                cell.categoryLabel.backgroundColor = category.tagColor
//            }
//            cell.categoryLabel.cornerRadiusMultipler = 2.5
//            cell.categoryLabel.textAlignment = .center
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//    
////    func collectionView(_ collectionView: UICollectionView,
////                        layout collectionViewLayout: UICollectionViewLayout,
////                        sizeForItemAt indexPath: IndexPath) -> CGSize {
////        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
////        let availableWidth = contentView.frame.width - paddingSpace
////        let widthPerItem = availableWidth / itemsPerRow
////        
////        return CGSize(width: widthPerItem, height: widthPerItem/5)
////    }
////
////    func collectionView(_ collectionView: UICollectionView,
////                        layout collectionViewLayout: UICollectionViewLayout,
////                        insetForSectionAt section: Int) -> UIEdgeInsets {
////        return sectionInsets
////    }
////
//    
////
////    func collectionView(_ collectionView: UICollectionView,
////                        layout collectionViewLayout: UICollectionViewLayout,
////                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
////        return sectionInsets.left
////    }
//    
//}
