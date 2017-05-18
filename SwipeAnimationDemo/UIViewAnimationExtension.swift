//
//  UIViewAnimationExtension.swift
//  SwipeAnimationDemo
//
//  Created by Eugenia Sakuda on 5/11/17.
//  Copyright © 2017 Eugenia Sakuda. All rights reserved.
//

import Foundation
import UIKit

public enum Direction: CGFloat {
    case left = -1.0
    case right = 1.0
    var oposite: Direction {
        switch self {
        case .left: return .right
        case .right: return .left
        }
    }
}
var anOriginalFrame:CGRect = CGRect.zero
fileprivate let scaleFactor: CGFloat = 30.0

public extension UIView {
    
    public typealias handler = ((Bool) -> Void)

    // TODO: is missing to correct cornerRadius property duiring animation
    public func animateBigger(from frame: CGRect? = .none, with direction: Direction, firstHandler: (() -> Void)? = .none, completionHandler: handler? = .none) {
        let originalFrame = frame ?? self.frame

        UIView.animate(withDuration: 1.5,
                       animations: { [unowned self] in
                            self.layer.zPosition = 0.9
                            self.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                        },
                       completion: { [unowned self] _ in
                            firstHandler?()
                            self.animateSmaller(upTo: originalFrame, with: direction, completionHandler: completionHandler)
                        })
    }
    
    public func animateSmaller(upTo frame: CGRect, with direction: Direction, completionHandler: handler? ) {
        
        UIView.animate(withDuration: 1.5,
                       delay: 1.0,
                       animations: { [unowned self] in
                            let xCenter = frame.origin.x < 0 ? self.screenWidth : 0
                            self.center = CGPoint(x: xCenter, y: self.screenHeight / 2)
                            self.transform = CGAffineTransform(scaleX: 1, y: 1)
                        },
                       completion: completionHandler)
    }
    
    public func restaureSize(upTo frame: CGRect, completionHandler: ((Bool) -> Void)? ) {
        UIView.animate(withDuration: 1.5,
                       animations: { [unowned self] in
                        self.frame = frame
                        self.layer.cornerRadius = self.frame.height / 2.0
                        self.layer.borderColor = UIColor.white.cgColor
            },
                       completion: completionHandler)
    }
    
    var screenWidth: CGFloat {
        let screenRect = UIScreen.main.bounds
        return screenRect.size.width
    }
    
    var screenHeight: CGFloat {
        let screenRect = UIScreen.main.bounds
        return screenRect.size.height
    }
    
    // TODO: Check and update this function's style - this function should not be use by now
    public func updateAnimation(with xTranslation: CGFloat, to frame: CGRect, with view: UIView, firstHandler: (() -> Void)? = .none, completionHandler: handler? = .none) {
        guard xTranslation != 0 else { return }
//        view.alpha = updatedAlpha(origin: frame.origin, xTranslation: xTranslation)
        let direction: Direction = xTranslation < 0 ? .left : .right
        var newSize = updatedSize(origin: frame.origin, xTranslation: xTranslation)
        let newPosition = updatedPosition(origin: frame.origin, newSize: newSize, with: direction)
        
        print("translation: \(xTranslation) - size: \(newSize) - position: \(newPosition)")
        
        if shouldCompleteAnimation(from: frame.origin, to: newPosition, with: direction) {
            animateBigger(from: frame, with: direction, firstHandler: firstHandler, completionHandler: completionHandler)
        } else {
            if frame.size.width > newSize.width {
                newSize = frame.size
            }
            self.frame = CGRect(origin: newPosition, size: newSize)
        }
    }
    
    public func fadeInAnimation(toShow: Bool) {
        alpha = toShow ? 0.0 : 1.0
        UIView.animate(withDuration: 0.5, animations: { [unowned self] in
            self.alpha = toShow ? 1.0 : 0.0
        })
    }
    
    public func fadeInOutAnimation() {
        alpha = 0.0
        layer.zPosition = 1.0
        UIView.animate(withDuration: 0.1,
                       animations: { [unowned self] in self.alpha = 1.0 },
                       completion: { [unowned self] _ in
                            UIView.animate(withDuration: 0.2,
                                           delay: 2.0,
                                           options: .curveEaseIn,
                                           animations: { [unowned self] in self.alpha = 0.0 })
        })
    }
    
    public func testAnimation() {
        
    }
}

fileprivate extension UIView {
    
    fileprivate func getEndPosition(from: CGRect, with direction: Direction) -> CGPoint {
        let basePosition = direction == .left ? -from.size.width / 2 : screenWidth - from.size.width / 2
        return CGPoint(x: basePosition, y: from.origin.y)
    }
    
    fileprivate func updatedPosition(origin: CGPoint, newSize: CGSize, with direction: Direction) -> CGPoint {
        let y = (screenHeight - abs(newSize.height)) / 2.0
        let multiplier = origin.x.sign()
        return CGPoint(x: frame.origin.x + CGFloat(multiplier) * (frame.size.width - abs(newSize.width)) / 2, y: y) // TODO: check this when having 2 arrows
    }
    
    fileprivate func updatedSize(origin: CGPoint, xTranslation: CGFloat) -> CGSize {
        let multiplier = origin.x.sign()
        let scale = 1.0 - CGFloat(multiplier) * xTranslation / screenWidth
        let size = frame.size
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    fileprivate func shouldCompleteAnimation(from origin: CGPoint, to newPosition: CGPoint, with direction: Direction) -> Bool {
        let rightViewIsBeingAnimated = origin.x.sign() > 0
        let leftViewShouldComplete = newPosition.x < screenWidth / 2 && direction == .left && rightViewIsBeingAnimated
        let rightViewShouldComplete = newPosition.x < -screenWidth / 2 && direction == .right && !rightViewIsBeingAnimated
        return leftViewShouldComplete || rightViewShouldComplete
    }
    
    // TODO: check. Alpha is 0 in the middle of the screen?
    fileprivate func updatedAlpha(origin: CGPoint, xTranslation: CGFloat) -> CGFloat {
//        let multiplier = origin.x.sign()
//        return alpha + 2 * CGFloat(multiplier) * xTranslation / screenWidth
        return 1.0
    }
    
}
