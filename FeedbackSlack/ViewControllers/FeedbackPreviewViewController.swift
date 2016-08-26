//
//  FeedbackPreviewViewController.swift
//  SlackTest
//
//  Created by Kazuya Ueoka on 2016/08/25.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

class FeedbackPreviewViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            if self.isViewLoaded() {
                self.imageView.image = self.image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
    }

    @IBAction func closeButtonDidTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FeedbackPreviewViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension FeedbackPreviewViewController: FS_TransitionDelegate {
    func transitionRect(transition: FS_Transition) -> CGRect {
        return UIApplication.sharedApplication().keyWindow?.bounds ?? UIScreen.mainScreen().bounds
    }

    func transitionImage(transition: FS_Transition) -> UIImage? {
        return self.image
    }
}

extension FeedbackPreviewViewController: FS_StoryboardInstantiatable {
    static var storyboardName: String {
        return "FeedbackSlackViewController"
    }

    static var storyboardIdentifier: String {
        return "feedbackPreviewViewController"
    }
}
