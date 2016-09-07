//
//  FeedbackSlack.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation
import ScreenRecord

@objc public enum FeedbackType: Int {
    case Photo
    case Video
}

@objc public class FeedbackSlack: NSObject {
    //public
    public let slackToken: String
    public let slackChannel: String
    public var options: String?
    public var trigger: String = UIApplicationUserDidTakeScreenshotNotification
    public var types: [FeedbackType] = [FeedbackType.Photo]

    //internal
    var subjects: [String]?
    var recordingView: RecordingView?
    private func setupRecordingView() {
        let view: RecordingView = RecordingView(frame: CGRect(x: 0.0, y: 0.0, width: UIApplication.sharedApplication().keyWindow?.frame.size.width ?? UIScreen.mainScreen().bounds.size.width, height: 20.0))
        view.delegate = self
        self.recordingView = view
    }

    private init(slackToken: String, slackChannel: String, subjects: [String]? = nil) {
        self.slackToken = slackToken
        self.slackChannel = slackChannel
        self.subjects = subjects
        super.init()
        ScreenRecord.shared.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.screenshotNotification(_:)), name: self.trigger, object: nil)
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

    func screenshotNotification(notification: NSNotification? = nil) {
        self.fire()
    }

    private var feedbacking: Bool = false
    public func fire(view: UIView? = UIApplication.sharedApplication().delegate?.window!) {
        guard let view = view where !self.feedbacking else {
            return
        }

        let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(delay, dispatch_get_main_queue()) { [unowned self] in
            if let type: FeedbackType = self.types.first where 1 == self.types.count {
                switch type {
                case FeedbackType.Photo:
                    self.takeScreenShot(view)
                case FeedbackType.Video:
                    self.takeScreenRecord(view)
                }
            } else if let window: UIWindow = UIApplication.sharedApplication().delegate?.window! where 1 < self.types.count {
                let alertController: UIAlertController = UIAlertController(title: nil, message: "フィードバックの方法を選択", preferredStyle: UIAlertControllerStyle.ActionSheet)
                if self.types.contains(FeedbackType.Photo) {
                    alertController.addAction(UIAlertAction(title: "スクリーンショット", style: UIAlertActionStyle.Default, handler: { [unowned self] (action: UIAlertAction) in
                        self.takeScreenShot(view)
                    }))
                }

                if self.types.contains(FeedbackType.Video) {
                    alertController.addAction(UIAlertAction(title: "動画", style: UIAlertActionStyle.Default, handler: { [unowned self] (action: UIAlertAction) in
                        self.takeScreenRecord(view)
                    }))
                }
                alertController.addAction(UIAlertAction(title: "Cacnel", style: UIAlertActionStyle.Cancel, handler: nil))

                window.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    public func takeScreenShot(view: UIView? = UIApplication.sharedApplication().delegate?.window!) {
        guard let view = view where self.feedbacking == false else {
            return
        }

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
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

    public func takeScreenRecord(view: UIView? = UIApplication.sharedApplication().delegate?.window!) {
        ScreenRecord.shared.start(view)

        self.setupRecordingView()
        self.recordingView?.makeKeyAndVisible()
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

extension FeedbackSlack: ScreenRecorderDelegate {
    public func screenRecordDidStart(screenRecord: ScreenRecord) {
        print(#function)
    }

    public func screenRecordDidStop(screenRecord: ScreenRecord) {
        print(#function)
    }

    public func screenRecord(screenRecord: ScreenRecord, didFailed error: ScreenRecord.Error) {
        print(#function, error)
    }

    public func screenRecordDidCompletion(screenRecord: ScreenRecord, url: NSURL?) {
        print(#function, url)

        self.recordingView?.removeFromSuperview()
        self.recordingView = nil
        UIApplication.sharedApplication().delegate?.window!?.makeKeyAndVisible()

        let viewController: FeedbackSlackViewController = FeedbackSlackViewController.instantitate()
        viewController.video = url

        self.sharedWindow.hidden = false
        self.sharedWindow.rootViewController = viewController
        self.sharedWindow.alpha = 0.0
        self.sharedWindow.makeKeyAndVisible()
        UIView.animateWithDuration(0.33, animations: { [unowned self] in
            self.sharedWindow.alpha = 10.0
        })
    }
}

extension FeedbackSlack: RecordingViewDelegate {
    func recordingViewDidTapped(recordingView: RecordingView) {
        if ScreenRecord.shared.isRecording {
            ScreenRecord.shared.stop()
        }
    }
}
