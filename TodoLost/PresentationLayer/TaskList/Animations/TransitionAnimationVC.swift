//
//  TransitionAnimationVC.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 29.06.2023.
//

import Foundation

import UIKit

final class TransitionAnimationVC: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.8
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return duration
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: .to)
        guard let view = presenting
                ? toView
                : transitionContext.view(forKey: .from) else { return }
        
        let initialFrame = presenting ? originFrame : view.frame
        let finalFrame = presenting ? view.frame : originFrame

        let xScaleFactor = presenting
        ? initialFrame.width / finalFrame.width
        : finalFrame.width / initialFrame.width

        let yScaleFactor = presenting
        ? initialFrame.height / finalFrame.height
        : finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(
            scaleX: xScaleFactor,
            y: yScaleFactor
        )
        
        if presenting {
            view.transform = scaleTransform
            view.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY
            )
            view.clipsToBounds = true
        }
        
        containerView.addSubview(view)
        containerView.bringSubviewToFront(view)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.1
        ) {
            view.transform = self.presenting
            ? .identity
            : scaleTransform
            view.center = CGPoint(
                x: finalFrame.midX,
                y: finalFrame.midY
            )
        } completion: { complete in
            transitionContext.completeTransition(complete)
        }
        
        if presenting == false {
            UIView.animate(withDuration: duration * 0.8) {
                view.alpha = 0.0
            }
        }
    }
}
