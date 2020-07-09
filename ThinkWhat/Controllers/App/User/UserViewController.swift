//
//  UserViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.05.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    var userProfile: UserProfile!
    fileprivate var isViewSetupCompleted = false
    fileprivate var circularImage: UIImage!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        container.setNeedsLayout()
        container.layoutIfNeeded()
        if !isViewSetupCompleted {
            self.userImage.image = circularImage
            self.isViewSetupCompleted = true
        }
    }
//    override func viewDidAppear(_ animated: Bool) {
//        //super.viewWillAppear(animated)
////        navigationItem.setHidesBackButton(true, animated: false)
//        if !isViewSetupCompleted {
//            view.setNeedsLayout()
//            view.layoutIfNeeded()
//            isViewSetupCompleted = true
//            if let _image = userProfile.image {
//                userImage.image = _image.circularImage(size: userImage.frame.size, frameColor: K_COLOR_RED)
//            }
//            usernameTF.text = userProfile.name
//            genderTF.text = "\(userProfile.age), \(userProfile.gender.rawValue)"
//        }
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        navigationItem.setHidesBackButton(false, animated: true)
//    }
    
    fileprivate func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        
//        DispatchQueue.main.async {
            var image = UIImage()
            if let _image = self.userProfile.image  {
                image = _image
            } else {
                image = UIImage(named: "user")!
            }
            self.circularImage     = image.circularImage(size: self.userImage.frame.size, frameColor: K_COLOR_RED)
            self.usernameTF.text   = self.userProfile.name
                        self.genderTF.text = "\(self.userProfile.age), \(self.userProfile.gender.rawValue)"
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based app lication, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
