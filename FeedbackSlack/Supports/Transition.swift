//
//  Transition.swift
//  SlackTest
//
//  Created by Kazuya Ueoka on 2016/08/25.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

protocol FS_TransitionDelegate {
    func transitionImage(transition: FS_Transition) -> UIImage?
    func transitionRect(transition: FS_Transition) -> CGRect
}
extension FS_TransitionDelegate {
    func transitionImage(transition: FS_Transition) -> UIImage? {
        return nil
    }

    func transitionRect(transition: FS_Transition) -> CGRect {
        return CGRect.zero
    }
}

class FS_Transition: NSObject {
    var present: Bool = true
    var presentDuration: NSTimeInterval = 0.33
    var dismissDuration: NSTimeInterval = 0.5
    var presentDelegate: FS_TransitionDelegate?
    var dismissDelegate: FS_TransitionDelegate?

    lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        return imageView
    }()

    var image: UIImage? {
        if self.present {
            return self.presentDelegate?.transitionImage(self)
        } else {
            return self.dismissDelegate?.transitionImage(self)
        }
    }

    var fromRect: CGRect {
        if self.present {
            return self.presentDelegate?.transitionRect(self) ?? CGRect.zero
        } else {
            return self.dismissDelegate?.transitionRect(self) ?? UIScreen.mainScreen().bounds
        }
    }
    var toRect: CGRect {
        if self.present {
            return self.dismissDelegate?.transitionRect(self) ?? UIScreen.mainScreen().bounds
        } else {
            return self.presentDelegate?.transitionRect(self) ?? CGRect.zero
        }
    }
}

extension FS_Transition: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.present = true
        return self
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.present = false
        return self
    }
}

extension FS_Transition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if self.present {
            return self.presentDuration
        } else {
            return self.dismissDuration
        }
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView: UIView = transitionContext.containerView(),
            fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }

        self.imageView.image = self.image
        self.imageView.frame = self.fromRect

        if self.present {
            containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
            toViewController.view.hidden = true
            fromViewController.view.hidden = false
        } else {
            containerView.insertSubview(fromViewController.view, aboveSubview: toViewController.view)
            toViewController.view.hidden = false
            fromViewController.view.hidden = true
        }
        containerView.addSubview(self.imageView)

        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveEaseInOut], animations: {
            self.imageView.frame = self.toRect
        }) { (finished: Bool) in
            if self.present {
                toViewController.view.hidden = false
            }
            self.imageView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
