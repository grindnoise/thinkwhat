//
//  NavigationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return children.last?.preferredStatusBarStyle ?? .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationBar.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        navigationBar.largeTitleTextAttributes = [
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.label
        ]
        navigationBar.titleTextAttributes = [
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.label
        ]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
//        navigationBar.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        navigationBar.largeTitleTextAttributes = [
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.label
        ]
        navigationBar.titleTextAttributes = [
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.label
        ]
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
