//
//  CostView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CostItem: Hashable {
  
  let id = UUID()
  var title: String
  var cost: Int
  
  init(title: String, cost: Int) {
    self.title = title
    self.cost = cost
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(cost)
  }
  
  static func == (lhs: CostItem, rhs: CostItem) -> Bool {
    lhs.id == rhs.id
  }
}

class CostView: UIView {
  
  private weak var parent: Popup?
  
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable, dataProvider: PollCreationControllerOutput?, parent: Popup?) {//}, result: Result<Bool,Error>?) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.dataProvider = dataProvider
        self.parent = parent
//        self.result = result
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
    
    // MARK: - Private methods
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
//        collectionView = CostCollectionView(dataProvider: dataProvider, parent: self)
        setObservers()
        setupUI()
    }
    
    private func setupUI() {
//        delayAsync(delay: 4) {
//            print(self.dataProvider?.result)
//        }
        guard let balance = dataProvider?.balance,
        let costItems = dataProvider?.costItems,
            let cost = costItems.reduce(into: 0) { $0 += $1.cost } as? Int,
            balance < cost else { return }
        stackView.removeArrangedSubview(confirm)
        confirm.alpha = 0
        //        stackView.removeArrangedSubview(cancel)
        //        cancel.alpha = 0
        
    }
    
    private func setObservers() {
        observers.append(observe(\CostView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view, change) in
            guard let self = self else { return }
            self.setText()
        })

        guard let c = dataProvider as? PollCreationView else { return }
        observers.append(c.observe(\PollCreationView.completed) { [weak self] (_,_) in
            guard let self = self,
            let indicator = self.contentView.get(all: LoadingIndicator.self).first as? LoadingIndicator else { return }
            let label = UILabel()
            label.alpha = 0
            label.textAlignment = .center
            label.addEquallyTo(to: self.container)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 1, options: .curveEaseOut) {
                indicator.alpha = 0
            } completion: { _ in
              indicator.stop()
//                indicator.removeAllAnimations()
                indicator.removeFromSuperview()
                
                switch c.result {
                case .success:
                    self.success = true
                    self.stackView.removeArrangedSubview(self.cancel)
                    self.cancel.alpha = 0
                    self.title.text = "success".localized
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: "poll_launched".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: self.container.bounds.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
                    label.attributedText = attrString
                case .failure(let error):
                    print(error.localizedDescription)
                    self.stackView.removeArrangedSubview(self.confirm)
                    self.confirm.alpha = 0
                    self.title.text = "error"
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: "backend_error".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: self.container.bounds.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
                    label.attributedText = attrString
                case .none:
                    print("")
                }
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.stackView.alpha = 1
                    self.title.alpha = 1
                    label.alpha = 1
                }
            }
        })
    }
    
    private func setText() {
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: "cost".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: title.bounds.height * 0.4), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = titleString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        cancel.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            guard let v = recognizer.view else { return }
            if v == confirm {
                guard success else {
                    dataProvider?.post()
//                    let indicator = LoadingIndicator(frame: .zero)
                  let indicator = LoadingIndicator(color: Colors.System.Red.rawValue)
                  indicator.start()
//                    indicator.alpha = 0
//                    indicator.addEnableAnimation()
                    contentView.addSubview(indicator)
                    indicator.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                        indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                        indicator.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),
                        indicator.widthAnchor.constraint(equalTo: indicator.heightAnchor, multiplier: 1.0/1.0),
                    ])
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in
                        guard let self = self else { return }
                        self.collectionView?.alpha = 0
                        self.title.alpha = 0
                        self.stackView.alpha = 0
                    } completion: { _ in }
                    return
                }
                callbackDelegate?.callbackReceived("pop")
            } else if v == cancel {
                callbackDelegate?.callbackReceived("exit")
            }
        }
    }
    
    // MARK: - Public methods
    public func onChildHeightChange(_ height: CGFloat) {
        parent?.onContainerHeightChange(height + title.bounds.height*2)
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var cancel: UIImageView! {
        didSet {
            cancel.isUserInteractionEnabled = true
            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            cancel.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        }
    }
    
    // MARK: - Properties
    private weak var callbackDelegate: CallbackObservable?
    private weak var dataProvider: PollCreationControllerOutput?
    private weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.addEquallyTo(to: container)
        }
    }
    private var observers: [NSKeyValueObservation] = []
    private var success = false
//    public var result: Result<Bool, Error>? {
//        didSet {
//            guard !result.isNil else { return }
//            switch result! {
//            case .success:
//                print("success")
//            default:
//                fatalError()
//            }
//        }
//    }
}

