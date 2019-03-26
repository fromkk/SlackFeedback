//
//  Transition.swift
//  SlackTest
//
//  Created by Kazuya Ueoka on 2016/08/25.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

protocol FS_TransitionDelegate {
    func transitionImage(_ transition: FS_Transition) -> UIImage?
    func transitionRect(_ transition: FS_Transition) -> CGRect
}
extension FS_TransitionDelegate {
    func transitionImage(_ transition: FS_Transition) -> UIImage? {
        return nil
    }

    func transitionRect(_ transition: FS_Transition) -> CGRect {
        return CGRect.zero
    }
}

class FS_Transition: NSObject {
    var present: Bool = true
    var presentDuration: TimeInterval = 0.33
    var dismissDuration: TimeInterval = 0.5
    var presentDelegate: FS_TransitionDelegate?
    var dismissDelegate: FS_TransitionDelegate?

    lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
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
            return self.dismissDelegate?.transitionRect(self) ?? UIScreen.main.bounds
        }
    }
    var toRect: CGRect {
        if self.present {
            return self.dismissDelegate?.transitionRect(self) ?? UIScreen.main.bounds
        } else {
            return self.presentDelegate?.transitionRect(self) ?? CGRect.zero
        }
    }
}

extension FS_Transition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.present = true
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.present = false
        return self
    }
}

extension FS_Transition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.present {
            return self.presentDuration
        } else {
            return self.dismissDuration
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView: UIView = transitionContext.containerView
        guard let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }

        self.imageView.image = self.image
        self.imageView.frame = self.fromRect

        if self.present {
            containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
            toViewController.view.isHidden = true
            fromViewController.view.isHidden = false
        } else {
            containerView.insertSubview(fromViewController.view, aboveSubview: toViewController.view)
            toViewController.view.isHidden = false
            fromViewController.view.isHidden = true
        }
        containerView.addSubview(self.imageView)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.imageView.frame = self.toRect
        }) { (finished: Bool) in
            if self.present {
                toViewController.view.isHidden = false
            }
            self.imageView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
