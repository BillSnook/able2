//
//  BLEView.swift
//  able2
//
//  Created by William Snook on 3/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



@IBDesignable
class BLEView: UIView {
    
//    var bandColor: UIColor = .clear
    
    @IBInspectable  var initialColor: UIColor? {
        didSet {
        }
    }
    
    var initialRadius: CGFloat = 0.0
    
    fileprivate var timerRunning = false
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }

    static func randomNumber(_ range: Range<Int> = Range(uncheckedBounds: (-8, 8)) ) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }

    func startPing() {
        delay( 0.15 + Double( BLEView.randomNumber(0..<50) ) / 100.0 ) {
            if self.timerRunning {          // If not stopped
                self.movePing()
                self.timerRunning = false
                self.startPing()
            }
        }
        timerRunning = true
    }
    
    func stopPing() {
        timerRunning = false
    }
    
    func movePing() {
//        Log.debug("movePing")
        let step = CGFloat(3.0)
        if initialRadius < ( ( self.frame.size.width - 40.0 - step ) / 2 ) {
            initialRadius += step
        } else {
            initialRadius = 0.0
            var xPosition = self.frame.origin.x
            var yPosition = self.frame.origin.y
            let xOffset = CGFloat(BLEView.randomNumber())
            let yOffset = CGFloat(BLEView.randomNumber())
            let newX = xPosition + xOffset
            let newY = yPosition + yOffset
            
            if ( newX < 0 ) || ( ( newX + self.frame.size.width ) > superview?.bounds.size.width ) {
                xPosition -= xOffset
            } else {
                xPosition += xOffset
            }
            self.frame.origin.x = xPosition
            
            if ( newY < 0 ) || ( ( newY + self.frame.size.height ) > superview?.bounds.size.height ) {
                yPosition -= yOffset
            } else {
                yPosition += yOffset
            }
            self.frame.origin.y = yPosition
        }
        setNeedsDisplay()
    }
 
    override func draw(_ rect: CGRect) {
        let startAngle: Float = Float(2 * Double.pi)
        let endAngle: Float = 0.0
        
        // Drawing code
        // Set the radius
        let strokeWidth = CGFloat(2.0)
        let strokeStep = CGFloat(4.0)
        
        // Get the context
        let context = UIGraphicsGetCurrentContext()
        
        // Find the middle of the circle
        let center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        // Set the stroke color
        if let strokeColor = initialColor {
            context?.setStrokeColor(strokeColor.cgColor)
        }
        // Set the line width
        context?.setLineWidth(strokeWidth)
        // Set the fill color (if you are filling the circle)
        context?.setFillColor(UIColor.clear.cgColor)
        
        // Draw the arc around the circle
        var tempRadius = CGFloat( initialRadius - 2 * strokeStep )
        if tempRadius <= 0.0 { tempRadius = 1.0 }
        while tempRadius <= initialRadius {
            context?.addArc(center: center, radius: tempRadius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
            context?.drawPath(using: .fillStroke) // or kCGPathFillStroke to fill and stroke the circle
            tempRadius += strokeStep
        }

    }
}
