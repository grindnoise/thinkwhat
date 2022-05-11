//
//  SurveyList.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyTable: UIView {

    deinit {
        print("HotView deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Initialization
    init(delegate: CallbackObservable) {
        super.init(frame: .zero)
        callbackDelegate = delegate
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setObservers()
        setupUI()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SurveyCell", bundle: nil), forCellReuseIdentifier: "survey")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscriptionsUpdated), name: Notifications.Surveys.UpdateSubscriptions, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.endRefreshing), name: Notifications.Surveys.ZeroSubscriptions, object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        tableView.sectionIndexBackgroundColor
    }
    
    @objc
    private func onSubscriptionsUpdated() {
        endRefreshing()
        tableView.reloadData()//reloadRows(at: [IndexPath(row: dataItems.endIndex, section: 0)], with: .bottom)
        
        // Sections(IndexSet(arrayLiteral: 0), with: .automatic)
//        layoutIfNeeded()
    }
    
    weak var callbackDelegate: CallbackObservable?
    private let refreshControl = UIRefreshControl()
    var dataItems: [SurveyReference] {
        return Surveys.shared.subscriptions
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
}

extension SurveyTable: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let instance = dataItems[indexPath.row] as? SurveyReference, let cell = tableView.dequeueReusableCell(withIdentifier: "survey", for: indexPath) as? SurveyCell else { return UITableViewCell() }
        cell.setupUI()
        cell.surveyReference = instance
//        superview?.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SurveyCell else { return }
        callbackDelegate?.callbackReceived(cell.surveyReference)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let biggestRow = tableView.indexPathsForVisibleRows?.sorted{ $1.row < $0.row }.first?.row, indexPath.row == biggestRow && indexPath.row == dataItems.count - 1 {
            callbackDelegate?.callbackReceived(self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func deselect() {
        guard let indexPath = tableView.indexPathsForSelectedRows?.first else { return }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc
    private func refresh() {
        callbackDelegate?.callbackReceived(self)
    }

    @objc
    private func endRefreshing() {
        refreshControl.endRefreshing()
    }
}
