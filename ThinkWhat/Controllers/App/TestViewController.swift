//
//  TestViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    deinit {
        print("")
        print("TestViewController deinit \(self)")
        print("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("")
        print("TestViewController init \(self)")
        print("")
        // Do any additional setup after loading the view.
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
