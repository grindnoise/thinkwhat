//
//  CategorySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController {

    class var subcategoryNib: UINib {
        return UINib(nibName: "SubcategorySelectionTableViewCell", bundle: nil)
    }
    class var categoryNib: UINib {
        return UINib(nibName: "CategoryTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func selectTapped(_ sender: Any) {
        if delegate != nil {
            delegate!.category = category
            delegate?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate var isViewSetupCompleted = false
    var delegate: NewSurveyViewController?
    var category: SurveyCategory? {
        didSet {
            if category != nil, selectButton != nil {
                UIView.animate(withDuration: 0.2) {
                    self.selectButton.backgroundColor = K_COLOR_RED
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
        tableView.register(CategorySelectionViewController.subcategoryNib, forCellReuseIdentifier: "subcategoryCell")
        tableView.register(CategorySelectionViewController.categoryNib, forCellReuseIdentifier: "categoryCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            isViewSetupCompleted = true
            self.selectButton.layer.cornerRadius = self.selectButton.frame.height / 2
        }
        if category == nil {
            selectButton.backgroundColor = K_COLOR_GRAY
        }
    }
}

extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SurveyCategories.shared.tree[section].first!.value.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SurveyCategories.shared.tree[section].first?.key
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell", for: indexPath) as? SubcategorySelectionTableViewCell {
            cell.title.text = SurveyCategories.shared.tree[indexPath.section].first?.value[indexPath.row].title.lowercased()//
            cell.category = SurveyCategories.shared.tree[indexPath.section].first?.value[indexPath.row]
            cell.isMarked = cell.category == category
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            } else {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SurveyCategories.shared.tree.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryTableViewCell {
            cell.title.text = SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.title.uppercased()
            cell.backgroundColor = SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.tagColor ?? UIColor.gray
            cell.total.text = "всего " + (SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.total.stringValue!)!
            cell.active.text = "активных " + (SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.active.stringValue!)!
            return cell
        }
        return nil
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryTableViewCell {
            return cell.contentView.frame.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SubcategorySelectionTableViewCell {
            if !cell.isMarked {
                cell.isMarked = true
                category = cell.category
                for c in tableView.visibleCells {
                    if let _cell = c as? SubcategorySelectionTableViewCell, _cell.isMarked, _cell != cell {
                        _cell.isMarked = false
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
