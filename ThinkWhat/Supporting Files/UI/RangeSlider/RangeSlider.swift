import UIKit

class RangeSlider: UIControl {
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    var minimumValue: CGFloat = 0.1 {
        didSet {
            updateLayerFrames()
        }
    }
    var maximumValue: CGFloat = 0.99 {
        didSet {
            updateLayerFrames()
        }
    }

    var lowerValue: CGFloat = 0.18 {
        didSet {
            updateLayerFrames()
        }
    }
    var upperValue: CGFloat = 0.40 {
        didSet {
            updateLayerFrames()
        }
    }
    var trackTintColor = UIColor(white: 0.8, alpha: 1)
    var trackHighlightTintColor = Colors.main.withAlphaComponent(0.6)
    var color = Colors.main {
        didSet {
            trackHighlightTintColor = color.withAlphaComponent(0.6)
        }
    }
    
    var thumbSize: CGSize = .zero
    
    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumb = CustomThumb()
    private let upperThumb = CustomThumb()
    private var previousLocation = CGPoint()
    
    init(frame: CGRect, color _color: UIColor) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        thumbSize = CGSize(width: bounds.height / 1.5, height: bounds.height / 1.5)
        lowerThumb.backgroundColor = _color
        lowerThumb.cornerRadius = thumbSize.height / 2
        lowerThumb.isUserInteractionEnabled = false
        upperThumb.backgroundColor = _color
        upperThumb.cornerRadius = thumbSize.height / 2
        upperThumb.isUserInteractionEnabled = false
        addSubview(lowerThumb)
        addSubview(upperThumb)
        
        updateLayerFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 1
    private func updateLayerFrames() {
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 2.25)
        trackLayer.setNeedsDisplay()
        lowerThumb.frame = CGRect(origin: thumbOriginForValue(lowerValue),
                                  size: thumbSize)
        upperThumb.frame = CGRect(origin: thumbOriginForValue(upperValue),
                                  size: thumbSize)
//        CATransaction.commit()
    }
    // 2
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    // 3
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbSize.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbSize.height) / 2.0)
    }
    
}

extension RangeSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if lowerThumb.frame.contains(previousLocation) {
            lowerThumb.isHighlighted = true
        } else if upperThumb.frame.contains(previousLocation) {
            upperThumb.isHighlighted = true
        }
        
        return lowerThumb.isHighlighted || upperThumb.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let superPreviousLocation = previousLocation
        let location = touch.location(in: self)
        
        // 1
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        
        previousLocation = location
        
        // 2
        if lowerThumb.isHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue,
                                    upperValue: upperValue)
            
            if lowerThumb.frame.intersects(upperThumb.frame), let intersection = lowerThumb.frame.intersection(upperThumb.frame) as? CGRect {
                previousLocation = superPreviousLocation
                lowerValue -= deltaValue
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                lowerThumb.frame.origin = CGPoint(x: lowerThumb.frame.origin.x - ceil(intersection.width), y: lowerThumb.frame.origin.y)
                CATransaction.commit()
                sendActions(for: .valueChanged)
                return false
            }
        } else if upperThumb.isHighlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue,
                                    upperValue: maximumValue)
            if upperThumb.frame.intersects(lowerThumb.frame), let intersection = upperThumb.frame.intersection(lowerThumb.frame) as? CGRect {
                previousLocation = superPreviousLocation
                upperValue -= deltaValue
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                upperThumb.frame.origin = CGPoint(x: upperThumb.frame.origin.x + ceil(intersection.width), y: upperThumb.frame.origin.y)
                CATransaction.commit()
                sendActions(for: .valueChanged)
                return false
            }
        }
        
        // 3
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    // 4
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat,
                            upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumb.isHighlighted = false
        upperThumb.isHighlighted = false
    }
}

class CustomThumb: UIView {
    var isHighlighted: Bool = false
}
