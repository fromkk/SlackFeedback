//
//  DrawableView.swift
//  SlackTest
//
//  Created by Kazuya Ueoka on 2016/09/07.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

class DrawableView: UIView {
    class Path {
        var points: [CGPoint] = []
        func add(point: CGPoint) {
            self.points.append(point)
        }
    }

    var currentPath: Path?
    var paths: [Path] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.userInteractionEnabled = true
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch: UITouch = touches.first else {
            return
        }

        let point: CGPoint = touch.locationInView(self)
        self.currentPath = Path()
        self.currentPath?.add(point)
        self.setNeedsDisplay()
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch: UITouch = touches.first else {
            return
        }

        self.move(touch.locationInView(self))
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch: UITouch = touches.first else {
            return
        }

        self.move(touch.locationInView(self))
        if let currentPath = self.currentPath {
            self.paths.append(currentPath)
        }

        self.currentPath = nil
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touch: UITouch = touches?.first else {
            return
        }

        self.move(touch.locationInView(self))
        if let currentPath = self.currentPath {
            self.paths.append(currentPath)
        }

        self.currentPath = nil
    }

    private func move(point: CGPoint) {
        if let currentPath = self.currentPath {
            currentPath.add(point)
            self.setNeedsDisplay()
        }
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        guard let context: CGContextRef = UIGraphicsGetCurrentContext() else {
            return
        }

        if let currentPath = self.currentPath {
            UIGraphicsPushContext(context)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, 5.0)
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            var didSet: Bool = false
            currentPath.points.forEach({ (point: CGPoint) in
                if !didSet {
                    CGContextMoveToPoint(context, point.x, point.y)
                    didSet = true
                } else {
                    CGContextAddLineToPoint(context, point.x, point.y)
                }
            })
            CGContextStrokePath(context)
            UIGraphicsPopContext()
        }

        self.paths.forEach { (path: Path) in
            UIGraphicsPushContext(context)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, 5.0)
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            var didSet: Bool = false
            path.points.forEach({ (point: CGPoint) in
                if !didSet {
                    CGContextMoveToPoint(context, point.x, point.y)
                    didSet = true
                } else {
                    CGContextAddLineToPoint(context, point.x, point.y)
                }
            })
            CGContextStrokePath(context)
            UIGraphicsPopContext()
        }
    }
}
