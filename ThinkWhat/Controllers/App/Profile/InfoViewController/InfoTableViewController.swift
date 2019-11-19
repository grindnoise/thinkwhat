//
//  InfoTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate      = self
        tableView.dataSource    = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(5) //
    }
}
