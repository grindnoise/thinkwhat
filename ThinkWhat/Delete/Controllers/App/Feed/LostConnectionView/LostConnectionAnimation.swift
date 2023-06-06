//
//  LostConnectionAnimation.swift
//
//  Code generated using QuartzCode 1.66.4 on 10.04.2020.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class LostConnectionAnimation: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var main : UIColor!
    var white : UIColor!
    var gray : UIColor!
    
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
        self.main = UIColor.black
        self.white = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        self.gray = UIColor.lightGray//UIColor(red:0.476, green: 0.476, blue:0.476, alpha:1)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
        let path = CAShapeLayer()
        self.layer.addSublayer(path)
        layers["path"] = path
        
        let web = CALayer()
        self.layer.addSublayer(web)
        layers["web"] = web
        let path2 = CAShapeLayer()
        web.addSublayer(path2)
        layers["path2"] = path2
        let path3 = CAShapeLayer()
        web.addSublayer(path3)
        layers["path3"] = path3
        let rectangle = CAShapeLayer()
        web.addSublayer(rectangle)
        layers["rectangle"] = rectangle
        let rectangle2 = CAShapeLayer()
        web.addSublayer(rectangle2)
        layers["rectangle2"] = rectangle2
        let rectangle3 = CAShapeLayer()
        web.addSublayer(rectangle3)
        layers["rectangle3"] = rectangle3
        
        let phone = CALayer()
        self.layer.addSublayer(phone)
        layers["phone"] = phone
        let back = CAShapeLayer()
        phone.addSublayer(back)
        layers["back"] = back
        let path4 = CAShapeLayer()
        phone.addSublayer(path4)
        layers["path4"] = path4
        
        let cross = CALayer()
        self.layer.addSublayer(cross)
        layers["cross"] = cross
        let back2 = CAShapeLayer()
        cross.addSublayer(back2)
        layers["back2"] = back2
        let path5 = CAShapeLayer()
        cross.addSublayer(path5)
        layers["path5"] = path5
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillColor   = self.gray.cgColor
            path.strokeColor = UIColor.black.cgColor
            path.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path2"){
            let path2 = layers["path2"] as! CAShapeLayer
            path2.fillRule    = .evenOdd
            path2.fillColor   = self.gray.cgColor
            path2.strokeColor = UIColor.black.cgColor
            path2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path3"){
            let path3 = layers["path3"] as! CAShapeLayer
            path3.fillRule    = .evenOdd
            path3.fillColor   = self.gray.cgColor
            path3.strokeColor = UIColor.black.cgColor
            path3.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle"){
            let rectangle = layers["rectangle"] as! CAShapeLayer
            rectangle.setValue(-90 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle.fillColor   = self.gray.cgColor
            rectangle.strokeColor = UIColor.black.cgColor
            rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle2"){
            let rectangle2 = layers["rectangle2"] as! CAShapeLayer
            rectangle2.fillColor   = self.gray.cgColor
            rectangle2.strokeColor = UIColor.black.cgColor
            rectangle2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle3"){
            let rectangle3 = layers["rectangle3"] as! CAShapeLayer
            rectangle3.fillColor   = self.gray.cgColor
            rectangle3.strokeColor = UIColor.black.cgColor
            rectangle3.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("back"){
            let back = layers["back"] as! CAShapeLayer
            back.fillColor   = self.white.cgColor
            back.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            back.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path4"){
            let path4 = layers["path4"] as! CAShapeLayer
            path4.fillRule    = .evenOdd
            path4.fillColor   = self.gray.cgColor
            path4.strokeColor = UIColor.black.cgColor
            path4.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("back2"){
            let back2 = layers["back2"] as! CAShapeLayer
            back2.fillColor   = self.white.cgColor
            back2.strokeColor = self.white.cgColor
            back2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path5"){
            let path5 = layers["path5"] as! CAShapeLayer
            path5.setValue(-45 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            path5.fillRule    = .evenOdd
            path5.fillColor   = self.gray.cgColor
            path5.strokeColor = UIColor.black.cgColor
            path5.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.11321 * path.superlayer!.bounds.width, y: 0.41068 * path.superlayer!.bounds.height, width: 0.139 * path.superlayer!.bounds.width, height: 0.1768 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let web = layers["web"]{
            web.frame = CGRect(x: 0.56754 * web.superlayer!.bounds.width, y: -0.00183 * web.superlayer!.bounds.height, width: 0.43413 * web.superlayer!.bounds.width, height: 1.00183 * web.superlayer!.bounds.height)
        }
        
        if let path2 = layers["path2"] as? CAShapeLayer{
            path2.frame = CGRect(x: 0, y: 0, width:  path2.superlayer!.bounds.width, height:  path2.superlayer!.bounds.height)
            path2.path  = path2Path(bounds: layers["path2"]!.bounds).cgPath
        }
        
        if let path3 = layers["path3"] as? CAShapeLayer{
            path3.frame = CGRect(x: 0.21967 * path3.superlayer!.bounds.width, y: 0, width: 0.56065 * path3.superlayer!.bounds.width, height:  path3.superlayer!.bounds.height)
            path3.path  = path3Path(bounds: layers["path3"]!.bounds).cgPath
        }
        
        if let rectangle = layers["rectangle"] as? CAShapeLayer{
            rectangle.transform = CATransform3DIdentity
            rectangle.frame     = CGRect(x: 0.02866 * rectangle.superlayer!.bounds.width, y: 0.47059 * rectangle.superlayer!.bounds.height, width: 0.94268 * rectangle.superlayer!.bounds.width, height: 0.05882 * rectangle.superlayer!.bounds.height)
            rectangle.setValue(-90 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle.path      = rectanglePath(bounds: layers["rectangle"]!.bounds).cgPath
        }
        
        if let rectangle2 = layers["rectangle2"] as? CAShapeLayer{
            rectangle2.frame = CGRect(x: 0.08104 * rectangle2.superlayer!.bounds.width, y: 0.24866 * rectangle2.superlayer!.bounds.height, width: 0.83409 * rectangle2.superlayer!.bounds.width, height: 0.05882 * rectangle2.superlayer!.bounds.height)
            rectangle2.path  = rectangle2Path(bounds: layers["rectangle2"]!.bounds).cgPath
        }
        
        if let rectangle3 = layers["rectangle3"] as? CAShapeLayer{
            rectangle3.frame = CGRect(x: 0.08104 * rectangle3.superlayer!.bounds.width, y: 0.68717 * rectangle3.superlayer!.bounds.height, width: 0.83409 * rectangle3.superlayer!.bounds.width, height: 0.05882 * rectangle3.superlayer!.bounds.height)
            rectangle3.path  = rectangle3Path(bounds: layers["rectangle3"]!.bounds).cgPath
        }
        
        if let phone = layers["phone"]{
            phone.frame = CGRect(x: 0, y: -0.00183 * phone.superlayer!.bounds.height, width: 0.25976 * phone.superlayer!.bounds.width, height: 1.00183 * phone.superlayer!.bounds.height)
        }
        
        if let back = layers["back"] as? CAShapeLayer{
            back.frame = CGRect(x: 0, y: 0.00384 * back.superlayer!.bounds.height, width:  back.superlayer!.bounds.width, height: 0.99616 * back.superlayer!.bounds.height)
            back.path  = backPath(bounds: layers["back"]!.bounds).cgPath
        }
        
        if let path4 = layers["path4"] as? CAShapeLayer{
            path4.frame = CGRect(x: 0, y: 0, width: 0.95437 * path4.superlayer!.bounds.width, height:  path4.superlayer!.bounds.height)
            path4.path  = path4Path(bounds: layers["path4"]!.bounds).cgPath
        }
        
        if let cross = layers["cross"]{
            cross.frame = CGRect(x: 0.35486 * cross.superlayer!.bounds.width, y: 0.34716 * cross.superlayer!.bounds.height, width: 0.21268 * cross.superlayer!.bounds.width, height: 0.30769 * cross.superlayer!.bounds.height)
        }
        
        if let back2 = layers["back2"] as? CAShapeLayer{
            back2.frame = CGRect(x: 0, y: 0, width:  back2.superlayer!.bounds.width, height:  back2.superlayer!.bounds.height)
            back2.path  = back2Path(bounds: layers["back2"]!.bounds).cgPath
        }
        
        if let path5 = layers["path5"] as? CAShapeLayer{
            path5.transform = CATransform3DIdentity
            path5.frame     = CGRect(x: 0.04702 * path5.superlayer!.bounds.width, y: 0.08125 * path5.superlayer!.bounds.height, width: 0.53289 * path5.superlayer!.bounds.width, height: 0.85 * path5.superlayer!.bounds.height)
            path5.setValue(-45 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            path5.path      = path5Path(bounds: layers["path5"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(){
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////An infinity animation
        
        let path = layers["path"] as! CAShapeLayer
        
        ////Path animation
        let pathPositionAnim         = CAKeyframeAnimation(keyPath:"position")
        pathPositionAnim.values      = [NSValue(cgPoint: CGPoint(x: 0.18271 * path.superlayer!.bounds.width, y: 0.49908 * path.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 0.43333 * path.superlayer!.bounds.width, y: 0.49908 * path.superlayer!.bounds.height))]
        pathPositionAnim.keyTimes    = [0, 1]
        pathPositionAnim.duration    = 1
        pathPositionAnim.repeatCount = Float.infinity
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathPositionAnim], fillMode:fillMode)
        path.add(pathEnableAnim, forKey:"pathEnableAnim")
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
        if identifier == "enable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathEnableAnim"), theLayer:layers["path"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["path"]?.removeAnimation(forKey: "pathEnableAnim")
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
        
        pathPath.move(to: CGPoint(x:minX + 0.3659 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.64028 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.64028 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.3659 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.72561 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.72561 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.27439 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.27439 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX, y: minY + h))
        
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
        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.06369 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.06369 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.25903 * w, y: minY + 0.06369 * h), controlPoint2:CGPoint(x:minX + 0.06369 * w, y: minY + 0.25903 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.93631 * h), controlPoint1:CGPoint(x:minX + 0.06369 * w, y: minY + 0.74097 * h), controlPoint2:CGPoint(x:minX + 0.25903 * w, y: minY + 0.93631 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.93631 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.74097 * w, y: minY + 0.93631 * h), controlPoint2:CGPoint(x:minX + 0.93631 * w, y: minY + 0.74097 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.06369 * h), controlPoint1:CGPoint(x:minX + 0.93631 * w, y: minY + 0.25903 * h), controlPoint2:CGPoint(x:minX + 0.74097 * w, y: minY + 0.06369 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.06369 * h))
        
        return path2Path
    }
    
    func path3Path(bounds: CGRect) -> UIBezierPath{
        let path3Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path3Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
        path3Path.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
        path3Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
        path3Path.close()
        path3Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.06369 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.11618 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.28802 * w, y: minY + 0.06369 * h), controlPoint2:CGPoint(x:minX + 0.11618 * w, y: minY + 0.25903 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.93631 * h), controlPoint1:CGPoint(x:minX + 0.11618 * w, y: minY + 0.74097 * h), controlPoint2:CGPoint(x:minX + 0.28802 * w, y: minY + 0.93631 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.88382 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.71198 * w, y: minY + 0.93631 * h), controlPoint2:CGPoint(x:minX + 0.88382 * w, y: minY + 0.74097 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.06369 * h), controlPoint1:CGPoint(x:minX + 0.88382 * w, y: minY + 0.25903 * h), controlPoint2:CGPoint(x:minX + 0.71198 * w, y: minY + 0.06369 * h))
        path3Path.close()
        path3Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.06369 * h))
        
        return path3Path
    }
    
    func rectanglePath(bounds: CGRect) -> UIBezierPath{
        let rectanglePath = UIBezierPath(rect:bounds)
        return rectanglePath
    }
    
    func rectangle2Path(bounds: CGRect) -> UIBezierPath{
        let rectangle2Path = UIBezierPath(rect:bounds)
        return rectangle2Path
    }
    
    func rectangle3Path(bounds: CGRect) -> UIBezierPath{
        let rectangle3Path = UIBezierPath(rect:bounds)
        return rectangle3Path
    }
    
    func backPath(bounds: CGRect) -> UIBezierPath{
        let backPath = UIBezierPath(rect:bounds)
        return backPath
    }
    
    func path4Path(bounds: CGRect) -> UIBezierPath{
        let path4Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path4Path.move(to: CGPoint(x:minX + 0.13446 * w, y: minY))
        path4Path.addCurve(to: CGPoint(x:minX, y: minY + 0.07738 * h), controlPoint1:CGPoint(x:minX + 0.0602 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.03464 * h))
        path4Path.addLine(to: CGPoint(x:minX, y: minY + 0.92262 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.13446 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.96536 * h), controlPoint2:CGPoint(x:minX + 0.0602 * w, y: minY + h))
        path4Path.addLine(to: CGPoint(x:minX + 0.86554 * w, y: minY + h))
        path4Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.92262 * h), controlPoint1:CGPoint(x:minX + 0.9398 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.96536 * h))
        path4Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.07738 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.86554 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.03464 * h), controlPoint2:CGPoint(x:minX + 0.9398 * w, y: minY))
        path4Path.addLine(to: CGPoint(x:minX + 0.13446 * w, y: minY))
        path4Path.close()
        path4Path.move(to: CGPoint(x:minX + 0.08101 * w, y: minY + 0.90893 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.91899 * w, y: minY + 0.90893 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.91899 * w, y: minY + 0.09107 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.08101 * w, y: minY + 0.09107 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.08101 * w, y: minY + 0.90893 * h))
        path4Path.close()
        path4Path.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.93036 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.45294 * w, y: minY + 0.95744 * h), controlPoint1:CGPoint(x:minX + 0.47401 * w, y: minY + 0.93036 * h), controlPoint2:CGPoint(x:minX + 0.45294 * w, y: minY + 0.94249 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.98452 * h), controlPoint1:CGPoint(x:minX + 0.45294 * w, y: minY + 0.9724 * h), controlPoint2:CGPoint(x:minX + 0.47401 * w, y: minY + 0.98452 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.54706 * w, y: minY + 0.95744 * h), controlPoint1:CGPoint(x:minX + 0.52599 * w, y: minY + 0.98452 * h), controlPoint2:CGPoint(x:minX + 0.54706 * w, y: minY + 0.9724 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.93036 * h), controlPoint1:CGPoint(x:minX + 0.54706 * w, y: minY + 0.94249 * h), controlPoint2:CGPoint(x:minX + 0.52599 * w, y: minY + 0.93036 * h))
        path4Path.close()
        path4Path.move(to: CGPoint(x:minX + 0.28486 * w, y: minY + 0.04414 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.27142 * w, y: minY + 0.05188 * h), controlPoint1:CGPoint(x:minX + 0.27744 * w, y: minY + 0.04414 * h), controlPoint2:CGPoint(x:minX + 0.27142 * w, y: minY + 0.04761 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.27142 * w, y: minY + 0.05625 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.28486 * w, y: minY + 0.06399 * h), controlPoint1:CGPoint(x:minX + 0.27142 * w, y: minY + 0.06052 * h), controlPoint2:CGPoint(x:minX + 0.27744 * w, y: minY + 0.06399 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.71514 * w, y: minY + 0.06399 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.72858 * w, y: minY + 0.05625 * h), controlPoint1:CGPoint(x:minX + 0.72256 * w, y: minY + 0.06399 * h), controlPoint2:CGPoint(x:minX + 0.72858 * w, y: minY + 0.06052 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.72858 * w, y: minY + 0.05188 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.71514 * w, y: minY + 0.04414 * h), controlPoint1:CGPoint(x:minX + 0.72858 * w, y: minY + 0.04761 * h), controlPoint2:CGPoint(x:minX + 0.72256 * w, y: minY + 0.04414 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.28486 * w, y: minY + 0.04414 * h))
        path4Path.close()
        path4Path.move(to: CGPoint(x:minX + 0.28486 * w, y: minY + 0.04414 * h))
        
        return path4Path
    }
    
    func back2Path(bounds: CGRect) -> UIBezierPath{
        let back2Path = UIBezierPath(rect:bounds)
        return back2Path
    }
    
    func path5Path(bounds: CGRect) -> UIBezierPath{
        let path5Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path5Path.move(to: CGPoint(x:minX + 0.70588 * w, y: minY + 0.70588 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.70588 * w, y: minY + h))
        path5Path.addLine(to: CGPoint(x:minX + 0.29412 * w, y: minY + h))
        path5Path.addLine(to: CGPoint(x:minX + 0.29412 * w, y: minY + 0.70588 * h))
        path5Path.addLine(to: CGPoint(x:minX, y: minY + 0.70588 * h))
        path5Path.addLine(to: CGPoint(x:minX, y: minY + 0.29412 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.29412 * w, y: minY + 0.29412 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.29412 * w, y: minY))
        path5Path.addLine(to: CGPoint(x:minX + 0.70588 * w, y: minY))
        path5Path.addLine(to: CGPoint(x:minX + 0.70588 * w, y: minY + 0.29412 * h))
        path5Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.29412 * h))
        path5Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.70588 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.70588 * w, y: minY + 0.70588 * h))
        path5Path.close()
        path5Path.move(to: CGPoint(x:minX + 0.70588 * w, y: minY + 0.70588 * h))
        
        return path5Path
    }
    
    
}
