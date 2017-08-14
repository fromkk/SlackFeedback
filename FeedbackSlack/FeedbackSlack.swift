//
//  FeedbackSlack.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

@objc open class FeedbackSlack: NSObject {
    open let slackToken: String
    open let slackChannel: String
    open var enabled: Bool = true
    open var options: String?
    var subjects: [String]?
    fileprivate init(slackToken: String, slackChannel: String, subjects: [String]? = nil) {
        self.slackToken = slackToken
        self.slackChannel = slackChannel
        self.subjects = subjects
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackSlack.screenshotNotification(_:)), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
    }

    open static var shared: FeedbackSlack?
    fileprivate lazy var sharedWindow: UIWindow = {
        let result: UIWindow = UIWindow(frame: UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds)
        return result
    }()
    open static func setup(_ slackToken: String, slackChannel: String, subjects: [String]? = nil) -> FeedbackSlack? {
        if let feedback: FeedbackSlack = shared {
            return feedback
        }

        shared = FeedbackSlack(slackToken: slackToken, slackChannel: slackChannel, subjects: subjects)
        return shared
    }

    fileprivate var feedbacking: Bool = false
    @objc func screenshotNotification(_ notification: Notification) {
        guard let window: UIWindow = UIApplication.shared.delegate?.window!, !self.feedbacking, self.enabled else {
            return
        }

        self.feedbacking = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { [unowned self] in
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            let viewController: FeedbackSlackViewController = FeedbackSlackViewController.instantitate()
            viewController.image = image

            self.sharedWindow.isHidden = false
            self.sharedWindow.rootViewController = viewController
            self.sharedWindow.alpha = 0.0
            self.sharedWindow.makeKeyAndVisible()
            UIView.animate(withDuration: 0.33, animations: { [unowned self] in
                self.sharedWindow.alpha = 10.0
                })
        }
    }

    func close() {
        DispatchQueue.main.async { [unowned self] in
            self.sharedWindow.alpha = 1.0
            UIView.animate(withDuration: 0.33, animations: { [unowned self] in
                self.sharedWindow.alpha = 0.0
            }) { [unowned self] (finished: Bool) in
                self.sharedWindow.isHidden = true
                self.feedbacking = false
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            }
        }
    }
}
