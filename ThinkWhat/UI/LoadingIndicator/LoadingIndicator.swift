//
//  LoadingIndicator.swift
//
//  Code generated using QuartzCode 1.62.0 on 14.11.17.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class LoadingIndicator: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    
    
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
        
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0)
        
        let path = CAShapeLayer()
        self.layer.addSublayer(path)
        layers["path"] = path
        
        let path2 = CAShapeLayer()
        self.layer.addSublayer(path2)
        layers["path2"] = path2
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.opacity     = 0
            path.fillRule    = CAShapeLayerFillRule.evenOdd
            path.fillColor   = UIColor(red:0.806, green: 0.33, blue:0.339, alpha:1).cgColor
            path.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            path.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path2"){
            let path2 = layers["path2"] as! CAShapeLayer
            path2.opacity     = 0
            path2.fillRule    = CAShapeLayerFillRule.evenOdd
            path2.fillColor   = UIColor(red:0.806, green: 0.33, blue:0.339, alpha:0.751).cgColor
            path2.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            path2.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.42833 * path.superlayer!.bounds.width, y: 0.42833 * path.superlayer!.bounds.height, width: 0.14333 * path.superlayer!.bounds.width, height: 0.14333 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let path2 = layers["path2"] as? CAShapeLayer{
            path2.frame = CGRect(x: 0.42833 * path2.superlayer!.bounds.width, y: 0.42833 * path2.superlayer!.bounds.height, width: 0.14333 * path2.superlayer!.bounds.width, height: 0.14333 * path2.superlayer!.bounds.height)
            path2.path  = path2Path(bounds: layers["path2"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addUntitled1Animation(){
        let fillMode : String = CAMediaTimingFillMode.forwards.rawValue
        
        ////An infinity animation
        
        let path = layers["path"] as! CAShapeLayer
        
        ////Path animation
        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                            NSValue(caTransform3D: CATransform3DMakeScale(6, 6, 1))]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 3
        pathTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        pathTransformAnim.repeatCount    = Float.infinity
        
        let pathOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        pathOpacityAnim.values         = [0, 1, 0]
        pathOpacityAnim.keyTimes       = [0, 0.0506, 1]
        pathOpacityAnim.duration       = 3
        pathOpacityAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        pathOpacityAnim.repeatCount    = Float.infinity
        
        let pathUntitled1Anim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathOpacityAnim], fillMode:CAMediaTimingFillMode(rawValue: fillMode))
        path.add(pathUntitled1Anim, forKey:"pathUntitled1Anim")
        
        ////Path2 animation
        let path2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        path2OpacityAnim.values         = [0, 1, 0]
        path2OpacityAnim.keyTimes       = [0, 0.0506, 1]
        path2OpacityAnim.duration       = 3
        path2OpacityAnim.beginTime      = 1.5
        path2OpacityAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        path2OpacityAnim.repeatCount    = Float.infinity
        
        let path2 = layers["path2"] as! CAShapeLayer
        
        let path2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        path2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                             NSValue(caTransform3D: CATransform3DMakeScale(6, 6, 1))]
        path2TransformAnim.keyTimes       = [0, 1]
        path2TransformAnim.duration       = 3
        path2TransformAnim.beginTime      = 1.5
        path2TransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
        path2TransformAnim.repeatCount    = Float.infinity
        
        let path2Untitled1Anim : CAAnimationGroup = QCMethod.group(animations: [path2OpacityAnim, path2TransformAnim], fillMode:CAMediaTimingFillMode(rawValue: fillMode))
        path2.add(path2Untitled1Anim, forKey:"path2Untitled1Anim")
    }
    
    //MARK: - Animation Cleanup
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if let completionBlock = completionBlocks[anim]{
            completionBlocks.removeValue(forKey: anim)
            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
            }
            completionBlock(flag)
        }
    }
    
    func updateLayerValues(forAnimationId identifier: String){
        if identifier == "Untitled1"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathUntitled1Anim"), theLayer:layers["path"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path2"]!.animation(forKey: "path2Untitled1Anim"), theLayer:layers["path2"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "Untitled1"{
            layers["path"]?.removeAnimation(forKey: "pathUntitled1Anim")
            layers["path2"]?.removeAnimation(forKey: "path2Untitled1Anim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.02814 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.2394 * w, y: minY + 0.02814 * h), controlPoint2:CGPoint(x:minX + 0.02814 * w, y: minY + 0.2394 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.97186 * h), controlPoint1:CGPoint(x:minX + 0.02814 * w, y: minY + 0.7606 * h), controlPoint2:CGPoint(x:minX + 0.2394 * w, y: minY + 0.97186 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.97186 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.7606 * w, y: minY + 0.97186 * h), controlPoint2:CGPoint(x:minX + 0.97186 * w, y: minY + 0.7606 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h), controlPoint1:CGPoint(x:minX + 0.97186 * w, y: minY + 0.2394 * h), controlPoint2:CGPoint(x:minX + 0.7606 * w, y: minY + 0.02814 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
        
        return pathPath
    }
    
    func path2Path(bounds: CGRect) -> UIBezierPath{
        let path2Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
        path2Path.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
        path2Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.02814 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.2394 * w, y: minY + 0.02814 * h), controlPoint2:CGPoint(x:minX + 0.02814 * w, y: minY + 0.2394 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.97186 * h), controlPoint1:CGPoint(x:minX + 0.02814 * w, y: minY + 0.7606 * h), controlPoint2:CGPoint(x:minX + 0.2394 * w, y: minY + 0.97186 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.97186 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.7606 * w, y: minY + 0.97186 * h), controlPoint2:CGPoint(x:minX + 0.97186 * w, y: minY + 0.7606 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h), controlPoint1:CGPoint(x:minX + 0.97186 * w, y: minY + 0.2394 * h), controlPoint2:CGPoint(x:minX + 0.7606 * w, y: minY + 0.02814 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.02814 * h))
        
        return path2Path
    }
    
    
}

