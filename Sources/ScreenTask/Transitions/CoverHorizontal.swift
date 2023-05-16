//
//  File.swift
//  
//
//  Created by Vincent Lemonnier on 12/05/2023.
//

import UIKit

internal class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let presentingTransition: UIViewControllerAnimatedTransitioning?
    let dismissingTransition: UIViewControllerAnimatedTransitioning?
    
    init(presentingTransition: UIViewControllerAnimatedTransitioning?, dismissingTransition: UIViewControllerAnimatedTransitioning?) {
        self.presentingTransition = presentingTransition
        self.dismissingTransition = dismissingTransition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissingTransition
    }
}

internal extension TransitionDelegate {
    static let coverHorizontal = TransitionDelegate(presentingTransition: RightToLeftTransition(), dismissingTransition: LeftToRightTransition())
}

private class LeftToRightTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let shared = LeftToRightTransition()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.25 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!

        let initialFrame = fromViewController.view.frame

        fromViewController.view.frame = initialFrame
        toViewController.view.frame = initialFrame.offsetBy(dx: initialFrame.width * -0.3, dy: 0)
        
        fromViewController.view.layer.shadowOffset = .zero
        fromViewController.view.layer.shadowOpacity = 0.2
        fromViewController.view.layer.shadowRadius = 10
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                fromViewController.view.frame = initialFrame.offsetBy(dx: initialFrame.width, dy: 0)
                toViewController.view.frame = initialFrame
            },
            completion: { finished in
                fromViewController.view.frame = initialFrame.offsetBy(dx: initialFrame.width, dy: 0)
                fromViewController.view.layer.shadowOpacity = 0.0
                fromViewController.view.removeFromSuperview()
                toViewController.view.frame = initialFrame
                transitionContext.completeTransition(finished)
            }
        )
    }
}

private class RightToLeftTransition: NSObject, UIViewControllerAnimatedTransitioning {

    static let shared = RightToLeftTransition()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.25 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!

        let initialFrame = fromViewController.view.frame
        
        containerView.addSubview(toViewController.view)
        toViewController.view.frame = initialFrame.offsetBy(dx: initialFrame.width, dy: 0)
        toViewController.view.layer.shadowOffset = .zero
        toViewController.view.layer.shadowColor = UIColor.black.cgColor
        toViewController.view.layer.shadowOpacity = 0.2
        toViewController.view.layer.shadowRadius = 10
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                fromViewController.view.frame = initialFrame.offsetBy(dx: initialFrame.width * -0.3, dy: 0)
                toViewController.view.frame = initialFrame
            },
            completion: { finished in
                fromViewController.view.frame = initialFrame
                toViewController.view.frame = initialFrame
                toViewController.view.layer.shadowOpacity = 0.0
                transitionContext.completeTransition(finished)
            }
        )
    }
}
