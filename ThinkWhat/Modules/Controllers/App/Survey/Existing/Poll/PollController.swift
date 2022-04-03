//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollController: UIViewController {
    
    deinit {
        print("PollController deinit")
    }
    init(survey: Survey) {
        super.init(nibName: nil, bundle: nil)
        self._survey = survey
        self.surveyReference = _survey.reference
    }
    
    init(surveyReference: SurveyReference) {
        super.init(nibName: nil, bundle: nil)
        self.surveyReference = surveyReference
        if let instance = surveyReference.survey {
            self._survey = instance
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = PollModel()
               
        self.controllerOutput = view as? PollView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        setupUI()
        performChecks()
    }
    
    private func setupUI() {
        //Set icon category in title
        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        icon.backgroundColor = .clear
        icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        icon.isRounded = false
        icon.scaleMultiplicator = 1.4
        icon.category = Icon.Category(rawValue: surveyReference.topic.id) ?? .Null
        navigationItem.titleView = icon
        navigationItem.titleView?.clipsToBounds = false
//        navigationItem.backBarButtonItem?.title = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PollController.addFavorite))
        likeButton.addGestureRecognizer(gesture)
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.setNavigationBarHidden(false, animated: false)
//            nc.isShadowed = true
            nc.navigationBar.isTranslucent = false
        }
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(PollController.updateViewsCount(notification:)),
//                                               name: Notifications.UI.SuveyViewsCountReceived,
//                                               object: nil)
        navigationItem.largeTitleDisplayMode = .never
        guard surveyReference.isOwn else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: likeButton)]
            return
        }
    }
    
    private func performChecks() {
//        switch survey {
//        case .none:
//            tableView.alpha = 0
//            tableView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//            DispatchQueue.main.async {
//                self.loadingIndicator = ClockIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
//                self.loadingIndicator!.layer.masksToBounds = false
//                self.loadingIndicator!.layoutCentered(in: self.view, multiplier: 0.2)
//                self.loadingIndicator!.layer.zPosition = 1
//                self.loadingIndicator?.alpha = 1
//                self.loadingIndicator?.addEnableAnimation()
//            }
//            downloadPoll()
//        default:
//            switch survey?.isComplete {
//            case true:
//                API.shared.getSurveyStats(surveyReference: surveyRef) { result in
//                    switch result {
//                    case .success(let json):
//                        guard let views = json["views"].int, let results = json["result_total"].array else { return }
//                            NotificationCenter.default.post(name: Notifications.UI.SuveyViewsCountReceived, object: views)
//                        self.surveyRef.views = views
//
//                        var totalVotes = 0
//                        do {
//                            for entity in results {
//                                guard let dict = entity.dictionary else { continue }
//                                guard let data = try dict["userprofiles"]?.rawData() else { continue }
//                                guard let _answerID = dict["answer"]?.int else { continue }
//                                guard let answer = self.survey?.answers.filter({ $0.id == _answerID }).first, let _total = dict["total"]?.int else { continue }
//                                answer.totalVotes = _total
//                                totalVotes += _total
//                                let decoder = JSONDecoder()
//                                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
//                                                                           DateFormatter.dateTimeFormatter,
//                                                                           DateFormatter.dateFormatter ]
//                                let instances = try decoder.decode([Userprofile].self, from: data)
//                                for instance in instances {
//                                    if let existing = Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first {
//                                        answer.addVoter(existing)
//                                        continue
//                                    }
//                                    answer.addVoter(instance)
//                                }
//
//                                self.survey?.totalVotes = totalVotes
//                            }
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                        //TODO: - Update UI
//                        self.updateResults()
//                            self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
//                    case .failure(let error):
//                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
//                    }
//                }
//            case false:
//                API.shared.incrementViewCounter(surveyReference: surveyRef) { result in
//                    switch result {
//                    case .success(let json):
//                        guard let views = json["views"].int else { return }
//                        NotificationCenter.default.post(name: Notifications.UI.SuveyViewsCountReceived, object: views)
//                        self.surveyRef.views = views
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                    }
//                }
//            default:
//                fatalError("Shouldn't get here")
//            }
//
//        }
    }
//
//    @objc private func updateViewsCount(notification: Notification) {
//        controllerOutput?.onCountUpdated()
//    }

    @objc private func addFavorite() {
        guard !isLoading, !survey.isNil else { return }
        guard survey!.isComplete else {
            delBanner.shared.contentType = .Warning
            if let content = delBanner.shared.content as? Warning {
                content.level = .Info
                content.text = "Пройдите опрос для отслеживания результатов"
            }
            delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
            return
        }
        isLoading = true
        var mark = true
        if likeButton.state == .disabled {
            likeButton.state = .enabled
            mark = true
            if Array(Surveys.shared.favoriteReferences.keys).filter( {$0.id == surveyReference.id }).isEmpty { Surveys.shared.favoriteReferences[self.surveyReference] = Date() }
        } else {
            likeButton.state = .disabled
            mark = false
            if let key = Surveys.shared.favoriteReferences.keys.filter({ $0.id == surveyReference.id }).first {
                Surveys.shared.favoriteReferences.removeValue(forKey: key)
            }
        }
        NotificationCenter.default.post(name: Notifications.Surveys.FavoriteSurveysUpdated, object: nil)
        controllerInput?.addFavorite(mark)
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////                navigationController?.navigationBar.prefersLargeTitles = false
//        navigationItem.largeTitleDisplayMode = .never
//
//    }
    
    override func willMove(toParent parent: UIViewController?) {
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let icon = navigationItem.titleView as? Icon {
            switch traitCollection.userInterfaceStyle {
            case .light:
                icon.setIconColor(survey!.topic.tagColor)
            default:
                icon.setIconColor(.systemBlue)
            }
        }
    }
    
    // MARK: - Properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
    private var _survey: Survey!
    private var surveyReference: SurveyReference!
    private var isLoading = false
    private let likeButton = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
}

// MARK: - View Input
extension PollController: PollViewInput {
    func onClaim() {
        controllerInput?.claim()
    }
    
    func onAddFavorite(_ mark: Bool) {
        controllerInput?.addFavorite(mark)
    }
    
    var survey: Survey? {
        get {
            return _survey
        }
    }
}

// MARK: - Model Output
extension PollController: PollModelOutput {
    func onAddFavorite(_ result: Result<Bool, Error>) {
        isLoading = false
    }
    
    func onLoad(_ result: Result<Bool, Error>) {
        
    }
    
    func onCountUpdated() {
        controllerOutput?.onCountUpdated()
    }
}
