//
//  SurveyList.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyTable: UIView, SurveyDataSource {

    deinit {
        print("HotView deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Initialization
    init(delegate: CallbackObservable, category: Survey.SurveyCategory) {
        self.category = category
        super.init(frame: .zero)
        callbackDelegate = delegate
        commonInit()
    }
    
    init(delegate: CallbackObservable, topic: Topic) {
        self.topic = topic
        self.category = .Topic
        super.init(frame: .zero)
        callbackDelegate = delegate
        commonInit()
    }
    
    override init(frame: CGRect) {
        self.category = .All
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.category = .All
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
        let pagination = [Notifications.Surveys.UpdateSubscriptions,
                          Notifications.Surveys.UpdateTopSurveys,
                          Notifications.Surveys.UpdateOwn,
                          Notifications.Surveys.UpdateFavorite,
                          Notifications.Surveys.UpdateNewSurveys,]
        let zeroEmitted = [Notifications.Surveys.ZeroSubscriptions]
        
        pagination.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onPagination), name: $0, object: nil) }
        zeroEmitted.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.endRefreshing), name: $0, object: nil) }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    @objc
    private func onPagination() {
        endRefreshing()
        tableView.reloadData()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    weak var callbackDelegate: CallbackObservable?
    private let refreshControl = UIRefreshControl()
    var topic: Topic?
    var category: Survey.SurveyCategory {
        didSet {
            guard oldValue != category else { return }
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    private var dataItems: [SurveyReference] {
        if category == .Topic {
            return category.dataItems(topic)
        }
        return category.dataItems()
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
