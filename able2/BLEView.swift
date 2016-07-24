//
//  BLEView.swift
//  able2
//
//  Created by William Snook on 3/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class BLEView: UIView {
    
//    var bandColor: UIColor = .clear
    
    @IBInspectable  var initialColor: UIColor? {
        didSet {
        }
    }
    
    var initialRadius: CGFloat = 0.0
    
    private var timerRunning = false
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }

    static func randomNumber(range: Range<Int> = -8...8) -> Int {
        let min = range.startIndex
        let max = range.endIndex
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
 
    override func drawRect(rect: CGRect) {
        let startAngle: Float = Float(2 * M_PI)
        let endAngle: Float = 0.0
        
        // Drawing code
        // Set the radius
        let strokeWidth = CGFloat(2.0)
        let strokeStep = CGFloat(4.0)
        
        // Get the context
        let context = UIGraphicsGetCurrentContext()
        
        // Find the middle of the circle
        let center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        // Set the stroke color
        if let strokeColor = initialColor {
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        }
        // Set the line width
        CGContextSetLineWidth(context, strokeWidth)
        // Set the fill color (if you are filling the circle)
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        
        // Draw the arc around the circle
        var tempRadius = CGFloat( initialRadius - 2 * strokeStep )
        if tempRadius <= 0.0 { tempRadius = 1.0 }
        while tempRadius <= initialRadius {
            CGContextAddArc(context, center.x, center.y, tempRadius, CGFloat(startAngle), CGFloat(endAngle), 1)
            CGContextDrawPath(context, .FillStroke) // or kCGPathFillStroke to fill and stroke the circle
            tempRadius += strokeStep
        }

    }
}