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
            if self.isViewLoaded {
                self.imageView.image = self.image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
    }

    @IBAction func closeButtonDidTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FeedbackPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension FeedbackPreviewViewController: FS_TransitionDelegate {
    func transitionRect(_ transition: FS_Transition) -> CGRect {
        return UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
    }

    func transitionImage(_ transition: FS_Transition) -> UIImage? {
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
