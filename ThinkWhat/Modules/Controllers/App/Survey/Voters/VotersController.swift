//
//  VotersController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VotersController: UIViewController {

//    init(answer _answer: Answer, indexPath: IndexPath, color: UIColor) {
//        self._answer = _answer
//        self._indexPath = indexPath
//        self._color = color
//        super.init(nibName: nil, bundle: nil)
//    }
    
    init(answer _answer: Answer, color: UIColor) {
        self._answer = _answer
        self._color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = VotersModel()
               
        self.controllerOutput = view as? VotersView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        setFilterButton()
        setTitle()
        loadData()
    }
    
    private func setTitle() {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: "voted".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attrString.append(NSAttributedString(string: "\n\(answer.totalVotes)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        label.attributedText = attrString
        navigationItem.titleView = label
    }
    
    private func setFilterButton() {
        guard answer.voters.count > 1 else { return }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(VotersController.showFilter))
        filterButton.addGestureRecognizer(gesture)
        filterButton.contentMode = .scaleAspectFit
        filterButton.image = ImageSigns.filter.image
        filterButton.tintColor = .systemGray
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterButton)]
    }
    
    private func loadData() {
        requestAttempt += 1
        guard requestAttempt <= MAX_REQUEST_ATTEMPTS else {
            requestAttempt = 0
            controllerOutput?.onDataLoaded(.failure(AppError.server))
            return
        }
        controllerInput?.loadData()
    }
    
    @objc
    private func showFilter() {
        controllerOutput?.onFilterTapped()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !controllerOutput.isNil else { return }
        if isFilterEnabled {
            filterButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            filterButton.tintColor = .systemGray
        }
    }
    
    // MARK: - Properties
    var controllerOutput: VotersControllerOutput?
    var controllerInput: VotersControllerInput?
    private let _answer: Answer
//    private let _indexPath: IndexPath
    private let _color: UIColor
    private let filterButton = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
    private var isFilterEnabled = false
    private var filters: [String: AnyObject] = [:]
    private var requestAttempt = 0
}

// MARK: - View Input
extension VotersController: VotersViewInput {
    func setFilterEnabled(_ isOn: Bool) {
        isFilterEnabled = isOn
        if isOn {
            filterButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            filterButton.tintColor = .systemGray
        }
    }
    
//    var indexPath: IndexPath {
//        return _indexPath
//    }
    
    var answer: Answer {
        return _answer
    }
    
    var color: UIColor {
        return _color
    }
}

// MARK: - Model Output
extension VotersController: VotersModelOutput {
    func onDataLoaded(_ result: Result<[Userprofile], Error> ){
        switch result {
        case .success:
            controllerOutput?.onDataLoaded(result)
        case .failure(let error):
#if DEBUG
            print(error)
#endif
            loadData()
        }
    }
}

