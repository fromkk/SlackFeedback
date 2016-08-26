//
//  FeedbackSlack.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

@objc public class FeedbackSlack: NSObject {
    public let slackToken: String
    public let slackChannel: String
    public var options: String?
    var subjects: [String]?
    private init(slackToken: String, slackChannel: String, subjects: [String]? = nil) {
        self.slackToken = slackToken
        self.slackChannel = slackChannel
        self.subjects = subjects
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.screenshotNotification(_:)), name: UIApplicationUserDidTakeScreenshotNotification, object: nil)
    }

    public static var shared: FeedbackSlack?
    private lazy var sharedWindow: UIWindow = {
        let result: UIWindow = UIWindow(frame: UIApplication.sharedApplication().keyWindow?.bounds ?? UIScreen.mainScreen().bounds)
        return result
    }()
    public static func setup(slackToken: String, slackChannel: String, subjects: [String]? = nil) -> FeedbackSlack? {
        if let feedback: FeedbackSlack = shared {
            return feedback
        }

        shared = FeedbackSlack(slackToken: slackToken, slackChannel: slackChannel, subjects: subjects)
        return shared
    }

    private var feedbacking: Bool = false
    func screenshotNotification(notification: NSNotification) {
        guard let window: UIWindow = UIApplication.sharedApplication().delegate?.window! where !self.feedbacking else {
            return
        }

        self.feedbacking = true
        let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(delay, dispatch_get_main_queue()) {
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
            window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: true)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let viewController: FeedbackSlackViewController = FeedbackSlackViewController.instantitate()
            viewController.image = image

            self.sharedWindow.hidden = false
            self.sharedWindow.rootViewController = viewController
            self.sharedWindow.alpha = 0.0
            self.sharedWindow.makeKeyAndVisible()
            UIView.animateWithDuration(0.33, animations: { [unowned self] in
                self.sharedWindow.alpha = 10.0
            })
        }
    }

    func close() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.sharedWindow.alpha = 1.0
            UIView.animateWithDuration(0.33, animations: { [unowned self] in
                self.sharedWindow.alpha = 0.0
            }) { [unowned self] (finished: Bool) in
                self.sharedWindow.hidden = true
                self.feedbacking = false
                UIApplication.sharedApplication().delegate?.window??.makeKeyAndVisible()
            }
        }
    }
}
