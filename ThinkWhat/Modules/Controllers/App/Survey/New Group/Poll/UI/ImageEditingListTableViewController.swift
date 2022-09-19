////
////  ImageEditingListView.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 29.04.2021.
////  Copyright © 2021 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class ImageEditingListTableViewController: UITableViewController {
//
//    var delegate: CallbackObservable?
//
//    @IBOutlet weak var openIcon: Icon! {
//        didSet {
//            openIcon.iconColor = .black
//            openIcon.category = .Zoom
//        }
//    }
//    @IBOutlet weak var replaceIcon: Icon! {
//        didSet {
//            replaceIcon.iconColor = .black
//            replaceIcon.category = .Replace
//        }
//    }
//    @IBOutlet weak var deleteIcon: Icon! {
//        didSet {
//            deleteIcon.iconColor = K_COLOR_RED
//            deleteIcon.category = .Trash
//        }
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        tableView.delegate      = self
////        tableView.dataSource    = self
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var identifier = ""
//
//        if indexPath.row == 0 {
//            identifier = "openImage"
//        } else if indexPath.row == 1{
//            identifier = "replaceImage"
//        } else {
//            identifier = "deleteImage"
//        }
//
//        delegate?.callbackReceived(identifier as AnyObject)
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView.frame.size.height / CGFloat(3)
//    }
//
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.11, delayFactor: 0.01)
//        let animator = Animator(animation: animation)
//        animator.animate(cell: cell, at: indexPath, in: tableView)
//    }
//
//}
