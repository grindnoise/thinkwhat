//
//  LoadingIndicator.swift
//
//  Code generated using QuartzCode 1.62.0 on 14.11.17.
//  www.quartzcodeapp.com
//

import UIKit
import Combine

class LoadingIndicator: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public var color: UIColor {
    didSet {
      guard oldValue != color else {  return }
      
      logo.setIconColor(color)
    }
  }
  ///`Publishers`
  public let didDisappearPublisher = PassthroughSubject<Bool, Never>()//: PassthroughSubject<Bool, Never>!
  ///`UI`
  public var duration: TimeInterval
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private lazy var logo: Icon = {
    let instance = Icon(frame: frame,
                        category: .Logo,
                        scaleMultiplicator: 1,
                        iconColor: color)
    instance.alpha = 0
    
    return instance
  }()
  private var colorAnimation: CAAnimation?
  private var scaleAnimation: CAAnimation?
  ///`Logic`
  private let shouldSendCompletion: Bool
  private var colorAnimationStopped = false {
    didSet {
      guard /*!oldValue && */colorAnimationStopped && scaleAnimationStopped else { return }
      colorAnimation = nil
      scaleAnimation = nil
      animationsStopped.send(true)
    }
  }
  private var scaleAnimationStopped = false
  private let animationsStopped = PassthroughSubject<Bool, Never>()
  private var shouldStopAnimating = false
  private var isAnimating = false
  
  
  // MARK: - Deinitialization
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  init(color: UIColor,
       duration: TimeInterval = 1,
       shouldSendCompletion: Bool = true) {
    self.duration = duration
    self.color = color
    self.shouldSendCompletion = shouldSendCompletion
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  @MainActor
  public func start(animated: Bool = true) {
    guard !isAnimating else {
//      delayAsync(delay: 0.25) { [weak self] in
//        guard let self = self else { return }
//
//        self.start(animated: animated)
//      }
      
      return
    }
    
//    isAnimating = true
//    didDisappearPublisher = PassthroughSubject<Bool, Never>()
    
    guard animated else {
      logo.alpha = 1
      animate()
      
      return
    }
    
    logo.transform = .init(scaleX: 0.75, y: 0.75)
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.logo.alpha = 1
        self.logo.transform = .identity
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.animate()
      }
  }
  
//  public func reset() {
//    colorAnimationStopped = false
//    scaleAnimationStopped = false
////    private let animationsStopped = PassthroughSubject<Bool, Never>()
//    shouldStopAnimating = false
////    didDisappearPublisher = PassthroughSubject<Bool, Never>()
//  }
  
  @MainActor
  public func stop(reset: Bool = false) {
    shouldStopAnimating = true
    
    animationsStopped
      .sink { [weak self]_  in
        guard let self = self else { return }
        
        UIView.animate(
          withDuration: 0.25,
          delay: 0,
          options: [.curveEaseInOut],
          animations: { [weak self] in
            guard let self = self else { return }
            
            self.logo.transform = .init(scaleX: 0.5, y: 0.5)
            self.logo.alpha = 0
          }) { [weak self] _ in
            guard let self = self else { return }
            
            self.logo.icon.removeAllAnimations()
            self.didDisappearPublisher.send(true)
            
            guard reset else { return }
            
            self.colorAnimationStopped = false
            self.scaleAnimationStopped = false
            self.shouldStopAnimating = false
            
            guard self.shouldSendCompletion else { return }
            
            self.didDisappearPublisher.send(completion: .finished)
          }
      }
      .store(in: &subscriptions)
  }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension LoadingIndicator {
  @MainActor
  func setupUI() {
    clipsToBounds = false
    heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1/1).isActive = true
    backgroundColor = .clear
    logo.place(inside: self)
  }
  
  @MainActor
  func animate() {//from: UIColor, to: UIColor) {
//    guard !isAnimating else { return }
    isAnimating = true
    
    colorAnimation = Animations.get(property: .FillColor,
                                    fromValue: color.cgColor as Any,
                                    toValue: color.withAlphaComponent(0.75).cgColor as Any,
                                    duration: duration,
                                    delay: 0,
                                    repeatCount: 1,
                                    autoreverses: true,
                                    timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: true,
                                    completionBlocks: [
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.isAnimating = false
                                        
                                        if self.shouldStopAnimating {
//                                          self.colorAnimation = nil
                                          self.colorAnimationStopped = true
//                                          self.scaleAnimationStopped = true
                                        } else {
                                          self.animate()
                                        }
                                      }])
    scaleAnimation = Animations.get(property: .Path,
                                    fromValue: (logo.icon as! CAShapeLayer).path as Any,
                                    toValue: (logo.icon as! CAShapeLayer).path?.getScaledPath(size: bounds.size, scaleMultiplicator: 1.15) as Any,
                                    duration: duration,
                                    delay: 0,
                                    repeatCount: 1,
                                    autoreverses: true,
                                    timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: true,
                                    completionBlocks: [
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.isAnimating = false
                                        
                                        if self.shouldStopAnimating {
//                                          self.scaleAnimation = nil
                                          self.scaleAnimationStopped = true
                                        } else {
                                          self.animate()
                                        }
                                      }])
    
    logo.icon.add(scaleAnimation!, forKey: nil)
    logo.icon.add(colorAnimation!, forKey: nil)
  }
}

extension LoadingIndicator: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
        completionBlock()
      }
    }
  }
}

//import UIKit
//
//@IBDesignable
//class LoadingIndicator: UIView, CAAnimationDelegate {
//
//    var layers = [String: CALayer]()
//    var completionBlocks = [CAAnimation: (Bool) -> Void]()
//    var updateLayerValueForCompletedAnimation : Bool = false
//    var color = K_COLOR_RED {
//        didSet {
//            resetLayerProperties(forLayerIdentifiers: nil)
//        }
//    }
//
//    //MARK: - Life Cycle
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupProperties()
//        setupLayers()
//    }
//
//    init(frame: CGRect, color _color: UIColor = K_COLOR_RED) {
//        self.color = _color
//        super.init(frame: frame)
//        setupProperties()
//        setupLayers()
//    }
//
//    required init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//        setupProperties()
//        setupLayers()
//    }
//
//    override var frame: CGRect{
//        didSet{
//            setupLayerFrames()
//        }
//    }
//
//    override var bounds: CGRect{
//        didSet{
//            setupLayerFrames()
//        }
//    }
//
//    func setupProperties(){
//
//    }
//
//    func setupLayers(){
//        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0)
//
//        let path = CAShapeLayer()
//        self.layer.addSublayer(path)
//        layers["path"] = path
//
//        let path2 = CAShapeLayer()
//        self.layer.addSublayer(path2)
//        layers["path2"] = path2
//
//        resetLayerProperties(forLayerIdentifiers: nil)
//        setupLayerFrames()
//    }
//
//    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        if layerIds == nil || layerIds.contains("path"){
//            let path = layers["path"] as! CAShapeLayer
//            path.opacity     = 0
//            path.fillRule    = CAShapeLayerFillRule.evenOdd
//            path.fillColor   = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : color.cgColor//UIColor(red:0.806, green: 0.33, blue:0.339, alpha:1).cgColor
//            path.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : color.cgColor//UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
//            path.lineWidth   = 0
//        }
//        if layerIds == nil || layerIds.contains("path2"){
//            let path2 = layers["path2"] as! CAShapeLayer
//            path2.opacity     = 0
//            path2.fillRule    = CAShapeLayerFillRule.evenOdd
//            path2.fillColor   = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.withAlphaComponent(0.7).cgColor : color.withAlphaComponent(0.7).cgColor//UIColor(red:0.806, green: 0.33, blue:0.339, alpha:0.751).cgColor
//            path2.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : color.cgColor//UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
//            path2.lineWidth   = 0
//        }
//
//        CATransaction.commit()
//    }
//
//    func setupLayerFrames(){
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        if let path = layers["path"] as? CAShapeLayer{
//            path.frame = CGRect(x: 0.42833 * path.superlayer!.bounds.width, y: 0.42833 * path.superlayer!.bounds.height, width: 0.14333 * path.superlayer!.bounds.width, height: 0.14333 * path.superlayer!.bounds.height)
//            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
//        }
//
//        if let path2 = layers["path2"] as? CAShapeLayer{
//            path2.frame = CGRect(x: 0.42833 * path2.superlayer!.bounds.width, y: 0.42833 * path2.superlayer!.bounds.height, width: 0.14333 * path2.superlayer!.bounds.width, height: 0.14333 * path2.superlayer!.bounds.height)
//            path2.path  = path2Path(bounds: layers["path2"]!.bounds).cgPath
//        }
//
//        CATransaction.commit()
//    }
//
//    //MARK: - Animation Setup
//
//    func addEnableAnimation(){
//        let fillMode : String = CAMediaTimingFillMode.forwards.rawValue
//
//        ////An infinity animation
//
//        let path = layers["path"] as! CAShapeLayer
//
//        ////Path animation
//        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
//        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
//                                            NSValue(caTransform3D: CATransform3DMakeScale(6, 6, 1))]
//        pathTransformAnim.keyTimes       = [0, 1]
//        pathTransformAnim.duration       = 3
//        pathTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
//        pathTransformAnim.repeatCount    = Float.infinity
//
//        let pathOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
//        pathOpacityAnim.values         = [0, 1, 0]
//        pathOpacityAnim.keyTimes       = [0, 0.0506, 1]
//        pathOpacityAnim.duration       = 3
//        pathOpacityAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
//        pathOpacityAnim.repeatCount    = Float.infinity
//
//        let pathUntitled1Anim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathOpacityAnim], fillMode:CAMediaTimingFillMode(rawValue: fillMode))
//        path.add(pathUntitled1Anim, forKey:"pathUntitled1Anim")
//
//        ////Path2 animation
//        let path2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
//        path2OpacityAnim.values         = [0, 1, 0]
//        path2OpacityAnim.keyTimes       = [0, 0.0506, 1]
//        path2OpacityAnim.duration       = 3
//        path2OpacityAnim.beginTime      = 1.5
//        path2OpacityAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
//        path2OpacityAnim.repeatCount    = Float.infinity
//
//        let path2 = layers["path2"] as! CAShapeLayer
//
//        let path2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
//        path2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
//                                             NSValue(caTransform3D: CATransform3DMakeScale(6, 6, 1))]
//        path2TransformAnim.keyTimes       = [0, 1]
//        path2TransformAnim.duration       = 3
//        path2TransformAnim.beginTime      = 1.5
//        path2TransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
//        path2TransformAnim.repeatCount    = Float.infinity
//
//        let path2Untitled1Anim : CAAnimationGroup = QCMethod.group(animations: [path2OpacityAnim, path2TransformAnim], fillMode:CAMediaTimingFillMode(rawValue: fillMode))
//        path2.add(path2Untitled1Anim, forKey:"path2Untitled1Anim")
//    }
//
//    //MARK: - Animation Cleanup
//
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
//        if let completionBlock = completionBlocks[anim]{
//            completionBlocks.removeValue(forKey: anim)
//            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
//                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
//                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
//            }
//            completionBlock(flag)
//        }
//    }
//
//    func updateLayerValues(forAnimationId identifier: String){
//        if identifier == "Untitled1"{
//            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathUntitled1Anim"), theLayer:layers["path"]!)
//            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path2"]!.animation(forKey: "path2Untitled1Anim"), theLayer:layers["path2"]!)
//        }
//    }
//
//    func removeAnimations(forAnimationId identifier: String){
//        if identifier == "Untitled1"{
//            layers["path"]?.removeAnimation(forKey: "pathUntitled1Anim")
//            layers["path2"]?.removeAnimation(forKey: "path2Untitled1Anim")
//        }
//    }
//
//    func removeAllAnimations(){
//        for layer in layers.values{
//            layer.removeAllAnimations()
//        }
//    }
//
//    //MARK: - Bezier Path
//
//    func pathPath(bounds: CGRect) -> UIBezierPath{
//        let pathPath = UIBezierPath()
//        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
//
//        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
//        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
//        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.02814 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.2394 * w, y: minY + 0.02814 * h), controlPoint2:CGPoint(x:minX + 0.02814 * w, y: minY + 0.2394 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.97186 * h), controlPoint1:CGPoint(x:minX + 0.02814 * w, y: minY + 0.7606 * h), controlPoint2:CGPoint(x:minX + 0.2394 * w, y: minY + 0.97186 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.97186 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.7606 * w, y: minY + 0.97186 * h), controlPoint2:CGPoint(x:minX + 0.97186 * w, y: minY + 0.7606 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h), controlPoint1:CGPoint(x:minX + 0.97186 * w, y: minY + 0.2394 * h), controlPoint2:CGPoint(x:minX + 0.7606 * w, y: minY + 0.02814 * h))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
//
//        return pathPath
//    }
//
//    func path2Path(bounds: CGRect) -> UIBezierPath{
//        let path2Path = UIBezierPath()
//        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
//
//        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
//        path2Path.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
//        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
//        path2Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
//        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
//        path2Path.close()
//        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
//        path2Path.addCurve(to: CGPoint(x:minX + 0.02814 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.2394 * w, y: minY + 0.02814 * h), controlPoint2:CGPoint(x:minX + 0.02814 * w, y: minY + 0.2394 * h))
//        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.97186 * h), controlPoint1:CGPoint(x:minX + 0.02814 * w, y: minY + 0.7606 * h), controlPoint2:CGPoint(x:minX + 0.2394 * w, y: minY + 0.97186 * h))
//        path2Path.addCurve(to: CGPoint(x:minX + 0.97186 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.7606 * w, y: minY + 0.97186 * h), controlPoint2:CGPoint(x:minX + 0.97186 * w, y: minY + 0.7606 * h))
//        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h), controlPoint1:CGPoint(x:minX + 0.97186 * w, y: minY + 0.2394 * h), controlPoint2:CGPoint(x:minX + 0.7606 * w, y: minY + 0.02814 * h))
//        path2Path.close()
//        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
//
//        return path2Path
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        resetLayerProperties(forLayerIdentifiers: nil)
////        switch traitCollection.userInterfaceStyle {
////        case .dark:
////            self.color = .systemBlue
////        default:
////            self.color = self.initialColor
////        }
//    }
//}
//
