//
//  VoteAnimationView.swift
//
//  Code generated using QuartzCode 1.66.4 on 06.04.2020.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class VoteAnimationView: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    
    var mainColor : UIColor!
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperties()
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupProperties()
        setupLayers()
    }
    
    override var frame: CGRect{
        didSet{
            setupLayerFrames()
        }
    }
    
    override var bounds: CGRect{
        didSet{
            setupLayerFrames()
        }
    }
    
    func setupProperties(){
        self.mainColor = K_COLOR_RED//UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
    }
    
    func setupLayers(){
        self.backgroundColor = .clear//UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
        let Group3 = CALayer()
        self.layer.addSublayer(Group3)
        layers["Group3"] = Group3
        let Group2 = CALayer()
        Group3.addSublayer(Group2)
        layers["Group2"] = Group2
        let Rectangle = CAShapeLayer()
        Group2.addSublayer(Rectangle)
        layers["Rectangle"] = Rectangle
        let Group = CALayer()
        Group2.addSublayer(Group)
        layers["Group"] = Group
        let RectangleCopy = CAShapeLayer()
        Group.addSublayer(RectangleCopy)
        layers["RectangleCopy"] = RectangleCopy
        let vote_group = CALayer()
        Group.addSublayer(vote_group)
        layers["vote_group"] = vote_group
        let rectangle = CAShapeLayer()
        vote_group.addSublayer(rectangle)
        layers["rectangle"] = rectangle
        let path = CAShapeLayer()
        vote_group.addSublayer(path)
        layers["path"] = path
        let CombinedShape = CAShapeLayer()
        vote_group.addSublayer(CombinedShape)
        layers["CombinedShape"] = CombinedShape
        let void_ = CAShapeLayer()
        Group.addSublayer(void_)
        layers["void_"] = void_
        let void_2 = CAShapeLayer()
        Group.addSublayer(void_2)
        layers["void_2"] = void_2
        let void_3 = CAShapeLayer()
        Group.addSublayer(void_3)
        layers["void_3"] = void_3
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("Rectangle"){
            let Rectangle = layers["Rectangle"] as! CAShapeLayer
            Rectangle.fillColor   = self.mainColor.cgColor
            Rectangle.strokeColor = UIColor.black.cgColor
            Rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("RectangleCopy"){
            let RectangleCopy = layers["RectangleCopy"] as! CAShapeLayer
            RectangleCopy.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            RectangleCopy.strokeColor = UIColor.black.cgColor
            RectangleCopy.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle"){
            let rectangle = layers["rectangle"] as! CAShapeLayer
            rectangle.fillColor   = UIColor.black.cgColor
            rectangle.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillRule    = .evenOdd
            path.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path.strokeColor = UIColor.black.cgColor
        }
        if layerIds == nil || layerIds.contains("CombinedShape"){
            let CombinedShape = layers["CombinedShape"] as! CAShapeLayer
            CombinedShape.setValue(-45 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            CombinedShape.fillColor   = self.mainColor.cgColor
            CombinedShape.strokeColor = UIColor.black.cgColor
            CombinedShape.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("void_"){
            let void_ = layers["void_"] as! CAShapeLayer
            void_.fillColor   = self.mainColor.cgColor
            void_.strokeColor = UIColor.black.cgColor
            void_.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("void_2"){
            let void_2 = layers["void_2"] as! CAShapeLayer
            void_2.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            void_2.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            void_2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("void_3"){
            let void_3 = layers["void_3"] as! CAShapeLayer
            void_3.fillColor   = self.mainColor.cgColor
            void_3.strokeColor = UIColor.black.cgColor
            void_3.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let Group3 = layers["Group3"]{
            Group3.frame = CGRect(x: 0.1 * Group3.superlayer!.bounds.width, y: 0.05 * Group3.superlayer!.bounds.height, width: 0.8 * Group3.superlayer!.bounds.width, height: 0.8 * Group3.superlayer!.bounds.height)
        }
        
        if let Group2 = layers["Group2"]{
            Group2.frame = CGRect(x: 0, y: 0, width:  Group2.superlayer!.bounds.width, height:  Group2.superlayer!.bounds.height)
        }
        
        if let Rectangle = layers["Rectangle"] as? CAShapeLayer{
            Rectangle.frame = CGRect(x: 0, y: 0.3125 * Rectangle.superlayer!.bounds.height, width:  Rectangle.superlayer!.bounds.width, height: 0.5 * Rectangle.superlayer!.bounds.height)
            Rectangle.path  = RectanglePath(bounds: layers["Rectangle"]!.bounds).cgPath
        }
        
        if let Group = layers["Group"]{
            Group.frame = CGRect(x: 0.00156 * Group.superlayer!.bounds.width, y: 0, width: 0.99844 * Group.superlayer!.bounds.width, height:  Group.superlayer!.bounds.height)
        }
        
        if let RectangleCopy = layers["RectangleCopy"] as? CAShapeLayer{
            RectangleCopy.frame = CGRect(x: 0.22349 * RectangleCopy.superlayer!.bounds.width, y: 0.48438 * RectangleCopy.superlayer!.bounds.height, width: 0.54881 * RectangleCopy.superlayer!.bounds.width, height: 0.04688 * RectangleCopy.superlayer!.bounds.height)
            RectangleCopy.path  = RectangleCopyPath(bounds: layers["RectangleCopy"]!.bounds).cgPath
        }
        
        if let vote_group = layers["vote_group"]{
            vote_group.frame = CGRect(x: 0.31142 * vote_group.superlayer!.bounds.width, y: 0, width: 0.37559 * vote_group.superlayer!.bounds.width, height: 0.375 * vote_group.superlayer!.bounds.height)
        }
        
        if let rectangle = layers["rectangle"] as? CAShapeLayer{
            rectangle.frame = CGRect(x: 0, y: 0, width:  rectangle.superlayer!.bounds.width, height:  rectangle.superlayer!.bounds.height)
            rectangle.path  = rectanglePath(bounds: layers["rectangle"]!.bounds).cgPath
        }
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.00417 * path.superlayer!.bounds.width, y: 0.00417 * path.superlayer!.bounds.height, width: 0.99167 * path.superlayer!.bounds.width, height: 0.99167 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let CombinedShape = layers["CombinedShape"] as? CAShapeLayer{
            CombinedShape.transform = CATransform3DIdentity
            CombinedShape.frame     = CGRect(x: 0.04311 * CombinedShape.superlayer!.bounds.width, y: 0.40542 * CombinedShape.superlayer!.bounds.height, width: 0.1699 * CombinedShape.superlayer!.bounds.width, height: 0.1108 * CombinedShape.superlayer!.bounds.height)
            CombinedShape.setValue(-45 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            CombinedShape.path      = CombinedShapePath(bounds: layers["CombinedShape"]!.bounds).cgPath
        }
        
        if let void_ = layers["void_"] as? CAShapeLayer{
            void_.frame = CGRect(x: 0.15493 * void_.superlayer!.bounds.width, y: 0.53125 * void_.superlayer!.bounds.height, width: 0.75117 * void_.superlayer!.bounds.width, height: 0.28125 * void_.superlayer!.bounds.height)
            void_.path  = void_Path(bounds: layers["void_"]!.bounds).cgPath
        }
        
        if let void_2 = layers["void_2"] as? CAShapeLayer{
            void_2.frame = CGRect(x: 0, y: 0.8125 * void_2.superlayer!.bounds.height, width:  void_2.superlayer!.bounds.width, height: 0.03438 * void_2.superlayer!.bounds.height)
            void_2.path  = void_2Path(bounds: layers["void_2"]!.bounds).cgPath
        }
        
        if let void_3 = layers["void_3"] as? CAShapeLayer{
            void_3.frame = CGRect(x: 0.06103 * void_3.superlayer!.bounds.width, y: 0.84375 * void_3.superlayer!.bounds.height, width: 0.87637 * void_3.superlayer!.bounds.width, height: 0.15625 * void_3.superlayer!.bounds.height)
            void_3.path  = void_3Path(bounds: layers["void_3"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(){
        let fillMode : CAMediaTimingFillMode = .forwards
        
        let vote_group = layers["vote_group"] as! CALayer
        
        ////Vote_group animation
        let vote_groupPositionAnim            = CAKeyframeAnimation(keyPath:"position")
        vote_groupPositionAnim.values         = [NSValue(cgPoint: CGPoint(x: 0.49922 * vote_group.superlayer!.bounds.width, y: 0.1875 * vote_group.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 0.49922 * vote_group.superlayer!.bounds.width, y: 0.78125 * vote_group.superlayer!.bounds.height))]
        vote_groupPositionAnim.keyTimes       = [0, 1]
        vote_groupPositionAnim.duration       = 0.7
        vote_groupPositionAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let vote_groupTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        vote_groupTransformAnim.values         = [0,
                                                  10 * CGFloat.pi/180]
        vote_groupTransformAnim.keyTimes       = [0, 1]
        vote_groupTransformAnim.duration       = 0.7
        vote_groupTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let vote_groupEnableAnim : CAAnimationGroup = QCMethod.group(animations: [vote_groupPositionAnim, vote_groupTransformAnim], fillMode:fillMode)
        vote_group.add(vote_groupEnableAnim, forKey:"vote_groupEnableAnim")
    }
    
    //MARK: - Animation Cleanup
    
    func updateLayerValues(forAnimationId identifier: String){
        if identifier == "enable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["vote_group"]!.animation(forKey: "vote_groupEnableAnim"), theLayer:layers["vote_group"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["vote_group"]?.removeAnimation(forKey: "vote_groupEnableAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func RectanglePath(bounds: CGRect) -> UIBezierPath{
        let RectanglePath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        RectanglePath.move(to: CGPoint(x:minX + 0.15 * w, y: minY))
        RectanglePath.addLine(to: CGPoint(x:minX + 0.85 * w, y: minY))
        RectanglePath.addLine(to: CGPoint(x:minX + w, y: minY + 0.875 * h))
        RectanglePath.addLine(to: CGPoint(x:minX + w, y: minY + h))
        RectanglePath.addLine(to: CGPoint(x:minX, y: minY + h))
        RectanglePath.addLine(to: CGPoint(x:minX, y: minY + 0.875 * h))
        RectanglePath.close()
        RectanglePath.move(to: CGPoint(x:minX + 0.15 * w, y: minY))
        
        return RectanglePath
    }
    
    func RectangleCopyPath(bounds: CGRect) -> UIBezierPath{
        let RectangleCopyPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        RectangleCopyPath.move(to: CGPoint(x:minX + 0.02273 * w, y: minY))
        RectangleCopyPath.addLine(to: CGPoint(x:minX + 0.97727 * w, y: minY))
        RectangleCopyPath.addLine(to: CGPoint(x:minX + w, y: minY + h))
        RectangleCopyPath.addLine(to: CGPoint(x:minX, y: minY + h))
        RectangleCopyPath.close()
        RectangleCopyPath.move(to: CGPoint(x:minX + 0.02273 * w, y: minY))
        
        return RectangleCopyPath
    }
    
    func rectanglePath(bounds: CGRect) -> UIBezierPath{
        let rectanglePath = UIBezierPath(rect:bounds)
        return rectanglePath
    }
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX, y: minY))
        pathPath.addLine(to: CGPoint(x:minX, y: minY + h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.23125 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23109 * w, y: minY + 0.25625 * h), controlPoint1:CGPoint(x:minX + 0.24238 * w, y: minY + 0.23125 * h), controlPoint2:CGPoint(x:minX + 0.23109 * w, y: minY + 0.24244 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.28125 * h), controlPoint1:CGPoint(x:minX + 0.23109 * w, y: minY + 0.27006 * h), controlPoint2:CGPoint(x:minX + 0.24238 * w, y: minY + 0.28125 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.81092 * w, y: minY + 0.28125 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.83613 * w, y: minY + 0.25625 * h), controlPoint1:CGPoint(x:minX + 0.82485 * w, y: minY + 0.28125 * h), controlPoint2:CGPoint(x:minX + 0.83613 * w, y: minY + 0.27006 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.81092 * w, y: minY + 0.23125 * h), controlPoint1:CGPoint(x:minX + 0.83613 * w, y: minY + 0.24244 * h), controlPoint2:CGPoint(x:minX + 0.82485 * w, y: minY + 0.23125 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.23125 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.475 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23109 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.24238 * w, y: minY + 0.475 * h), controlPoint2:CGPoint(x:minX + 0.23109 * w, y: minY + 0.48619 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.525 * h), controlPoint1:CGPoint(x:minX + 0.23109 * w, y: minY + 0.51381 * h), controlPoint2:CGPoint(x:minX + 0.24238 * w, y: minY + 0.525 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.81092 * w, y: minY + 0.525 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.83613 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.82485 * w, y: minY + 0.525 * h), controlPoint2:CGPoint(x:minX + 0.83613 * w, y: minY + 0.51381 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.81092 * w, y: minY + 0.475 * h), controlPoint1:CGPoint(x:minX + 0.83613 * w, y: minY + 0.48619 * h), controlPoint2:CGPoint(x:minX + 0.82485 * w, y: minY + 0.475 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.475 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.73125 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23109 * w, y: minY + 0.75625 * h), controlPoint1:CGPoint(x:minX + 0.24238 * w, y: minY + 0.73125 * h), controlPoint2:CGPoint(x:minX + 0.23109 * w, y: minY + 0.74244 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.78125 * h), controlPoint1:CGPoint(x:minX + 0.23109 * w, y: minY + 0.77006 * h), controlPoint2:CGPoint(x:minX + 0.24238 * w, y: minY + 0.78125 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.81092 * w, y: minY + 0.78125 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.83613 * w, y: minY + 0.75625 * h), controlPoint1:CGPoint(x:minX + 0.82485 * w, y: minY + 0.78125 * h), controlPoint2:CGPoint(x:minX + 0.83613 * w, y: minY + 0.77006 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.81092 * w, y: minY + 0.73125 * h), controlPoint1:CGPoint(x:minX + 0.83613 * w, y: minY + 0.74244 * h), controlPoint2:CGPoint(x:minX + 0.82485 * w, y: minY + 0.73125 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.73125 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.2563 * w, y: minY + 0.73125 * h))
        
        return pathPath
    }
    
    func CombinedShapePath(bounds: CGRect) -> UIBezierPath{
        let CombinedShapePath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        CombinedShapePath.move(to: CGPoint(x:minX + 0.21739 * w, y: minY + 0.66667 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.21739 * w, y: minY))
        CombinedShapePath.addLine(to: CGPoint(x:minX, y: minY))
        CombinedShapePath.addLine(to: CGPoint(x:minX, y: minY + 0.83333 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX, y: minY + h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY + h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY + 0.66667 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.21739 * w, y: minY + 0.66667 * h))
        CombinedShapePath.close()
        CombinedShapePath.move(to: CGPoint(x:minX + 0.21739 * w, y: minY + 0.66667 * h))
        
        return CombinedShapePath
    }
    
    func void_Path(bounds: CGRect) -> UIBezierPath{
        let void_Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        void_Path.move(to: CGPoint(x:minX, y: minY))
        void_Path.addLine(to: CGPoint(x:minX + w, y: minY))
        void_Path.addLine(to: CGPoint(x:minX + w, y: minY + h))
        void_Path.addLine(to: CGPoint(x:minX, y: minY + h))
        void_Path.close()
        void_Path.move(to: CGPoint(x:minX, y: minY))
        
        return void_Path
    }
    
    func void_2Path(bounds: CGRect) -> UIBezierPath{
        let void_2Path = UIBezierPath(rect:bounds)
        return void_2Path
    }
    
    func void_3Path(bounds: CGRect) -> UIBezierPath{
        let void_3Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        void_3Path.move(to: CGPoint(x:minX, y: minY))
        void_3Path.addLine(to: CGPoint(x:minX + w, y: minY))
        void_3Path.addLine(to: CGPoint(x:minX + w, y: minY + h))
        void_3Path.addLine(to: CGPoint(x:minX, y: minY + h))
        void_3Path.close()
        void_3Path.move(to: CGPoint(x:minX, y: minY))
        
        return void_3Path
    }
    
    
}
