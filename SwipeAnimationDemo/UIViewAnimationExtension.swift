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

public extension UIView {
    
    public typealias handler = ((Bool) -> Void)

    // TODO: is missing to correct cornerRadius property duiring animation
    public func animateBigger(from frame: CGRect? = .none, with direction: Direction, firstHandler: (() -> Void)? = .none, completionHandler: handler? = .none) {
        let originalFrame = frame ?? self.frame

        UIView.animate(withDuration: 2.0,
                       animations: { [unowned self] in
                            // TODO: this should be update if the logic is migrated to use beziers paths
                            self.frame.origin = CGPoint(x: -self.screenHeight/2, y: 0.0)
                            self.frame.size = CGSize(width: self.screenWidth + self.screenHeight, height: self.screenHeight)
                        },
                       completion: { [unowned self] _ in
                            self.layer.borderWidth = 0.0
                            self.layer.cornerRadius = 0.0
                            firstHandler?()
                            self.animateSmaller(upTo: originalFrame, with: direction, completionHandler: completionHandler)
                        })
    }
    
    public func animateSmaller(upTo frame: CGRect, with direction: Direction, completionHandler: handler? ) {
        let endPosition = getEndPosition(from: frame, with: direction)
        UIView.animate(withDuration: 2.0,
                       delay: 1.0,
                       animations: { [unowned self] in
                            self.frame.origin = endPosition
                            self.frame.size = frame.size
                            self.layer.cornerRadius = self.frame.height / 2.0
                            self.layer.borderColor = UIColor.white.cgColor
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
        return screenRect.size.height * 2
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
        UIView.animate(withDuration: 0.1,
                       animations: { [unowned self] in self.alpha = 1.0 },
                       completion: { [unowned self] _ in
                            UIView.animate(withDuration: 0.1,
                                           delay: 1.5,
                                           options: .curveEaseIn,
                                           animations: { [unowned self] in self.alpha = 0.0 })
        })
    }
    
    public func testAnimation() {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [cornerRadiusAnimation, sizeAnimation]
        animationGroup.duration = 2.0
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.isRemovedOnCompletion = false
        animationGroup.delegate = self
        layer.add(animationGroup, forKey: "bigger")
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

// Animation to make view bigger
fileprivate extension UIView {
    
    fileprivate var cornerRadiusAnimation: CAAnimation {
        let animation = CABasicAnimation();
        animation.keyPath = "cornerRadius";
        animation.fromValue = layer.cornerRadius
        animation.toValue = screenHeight/2
        return animation
    }
    
    fileprivate var sizeAnimation: CAAnimation {
        let size = CABasicAnimation()
        size.keyPath = "bounds.size"
        anOriginalFrame = frame
        size.fromValue = frame.size
        size.toValue = CGSize(width: screenWidth + screenHeight, height: screenHeight)
        return size
    }

}

// Animation to make view smaller
fileprivate extension UIView {
    
    fileprivate var smallerCornerRadiusAnimation: CAAnimation {
        let animation = CABasicAnimation();
        animation.keyPath = "cornerRadius";
        animation.fromValue = screenHeight/2
        animation.toValue = 50.0
        return animation
    }
    
    fileprivate var smallerPositionAnimation: CAAnimation {
        let animation = CABasicAnimation();
        animation.keyPath = "position";
        animation.toValue = CGRect(x: -50, y: anOriginalFrame.origin.y, width: 100, height: 100).origin
        return animation
    }
    
    fileprivate var smallerSizeAnimation: CAAnimation {
        let size = CABasicAnimation()
        size.keyPath = "bounds.size"
        size.fromValue = CGSize(width: screenWidth + screenHeight, height: screenHeight)
        //store the original position and use that
        size.toValue = CGSize(width: 100, height: 100)
        return size
    }

    
    
}

extension UIView: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        guard let isBigger = layer.animationKeys()?.contains("bigger") else { return }
        if isBigger {
            layer.removeAnimation(forKey: "bigger")

            frame.origin = CGPoint(x: -50, y: screenHeight/2 - 50)
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [smallerCornerRadiusAnimation, smallerSizeAnimation, smallerPositionAnimation]
            animationGroup.duration = 2.0
            animationGroup.delegate = self
            animationGroup.fillMode = kCAFillModeForwards;
            animationGroup.isRemovedOnCompletion = false
            layer.add(animationGroup, forKey: "smaller")
//            layer.removeAnimation(forKey: "bigger")
        }
        
    }
}
