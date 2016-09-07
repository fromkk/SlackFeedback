//
//  FeedbackSlackViewController.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit
import CoreTelephony
import AVFoundation
import MediaPlayer

class FeedbackSlackViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var defaultTopConstraint: CGFloat!
    @IBOutlet weak var closeButton: UIButton!
    var image: UIImage? {
        didSet {
            if self.isViewLoaded() {
                self.imageView.image = image
            }
        }
    }
    var video: NSURL? {
        didSet {
            guard let videoURL: NSURL = self.video else {
                return
            }

            let asset: AVURLAsset = AVURLAsset(URL: videoURL)
            let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            generator.maximumSize = self.view.bounds.size

            let midpoint = CMTimeMakeWithSeconds(1.0, 30)
            let capturedImage: CGImageRef? = try? generator.copyCGImageAtTime(midpoint, actualTime: nil)
            guard let cgImage = capturedImage else {
                return
            }

            let image: UIImage = UIImage(CGImage: cgImage)
            self.image = image
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subjectField: FSSelectionField!
    @IBOutlet weak var commentView: FSTextView!
    @IBOutlet weak var indicatorView: UIView!

    lazy var transition: FS_Transition = FS_Transition()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultTopConstraint = self.topConstraint.constant
        self.imageView.image = self.image

        if let subjects: [String] = FeedbackSlack.shared?.subjects {
            self.subjectField.items = subjects
        } else if let path: String = NSBundle(forClass: self.dynamicType).pathForResource("FeedbackSlack", ofType: "plist"),
            items: [String] = NSDictionary(contentsOfFile: path)?.objectForKey("subjects") as? [String] {
            self.subjectField.items = items
        }

        self.commentView.layer.borderWidth = 1.0
        self.commentView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        self.commentView.layer.cornerRadius = 3.0

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapGestureRecognizer(_:)))
        self.imageView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func closeButtonDidTapped(sender: AnyObject) {
        FeedbackSlack.shared?.close()
    }

    @IBAction func feedbackButtonDidTapped(sender: AnyObject) {
        let carrier: String = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? ""
        let reachability: Reachability = try! Reachability.reachabilityForInternetConnection()

        guard let subject: String = self.subjectField.selectedValue,
        appName: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String,
        version: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String,
        build: String = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String,
        language: String = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as? String,
        country: String = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        else {
            return
        }

        var comment: String = "内容：\(subject)\n"
        + "コメント：\(self.commentView.text)\n"
        + "-------------------\n"
        + "アプリ名：\(appName)\n"
        + "アプリバージョン：\(version)\n"
        + "ビルド番号：\(build)\n"
        + "端末名：\(UIDevice.currentDevice().name)\n"
        + "モデル：\(UIDevice.currentDevice().model)\n"
        + "OS名：\(UIDevice.currentDevice().systemName)\n"
        + "iOSバージョン：\(UIDevice.currentDevice().systemVersion)\n"
        + "言語：\(language)\n"
        + "国：\(country)\n"
        + "ネットワーク環境：\(reachability.currentReachabilityStatus.description)\n"
        + "キャリア名：\(carrier)"

        if let options = FeedbackSlack.shared?.options {
            comment += "\n-------------------\nオプション：\(options)"
        }

        self.postSlack(comment)
    }

    private func postSlack(comment: String) {
        guard let slack: FeedbackSlack = FeedbackSlack.shared,
            appName: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String
            else {
            return
        }

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.systemLocale()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date: String = dateFormatter.stringFromDate(NSDate())

        var fileName: String?
        var contentType: String?
        var data: NSData?
        if let video: NSURL = self.video {
            data = NSData(contentsOfURL: video)
            fileName = "\(NSDate().timeIntervalSince1970).m4v"
            contentType = "video/mp4"
        } else if let image: UIImage = self.image {
            data = UIImagePNGRepresentation(image)
            fileName = "\(NSDate().timeIntervalSince1970).png"
            contentType = "image/png"
        }

        guard let postData = data, let postFileName = fileName, let postContentType = contentType else {
            return
        }

        let fileUpload: FileUpload = FileUpload(token: slack.slackToken, data: postData, filename: postFileName, contentType: postContentType, title: "\(appName) feedback \(date)", initialComment: comment, channels: [slack.slackChannel])

        self.indicatorView.hidden = false
        let configration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session: NSURLSession = NSURLSession(configuration: configration)
        let task: NSURLSessionTask = session.dataTaskWithRequest(fileUpload.request) { [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let data = data {
                do {
                    let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    if json["ok"] as? Int == 1 {
                        FeedbackSlack.shared?.close()
                    }
                } catch {
                    print("json serialization failed")
                }

            } else if let error = error {
                print("error:\(error)")
            }

            self?.indicatorView.hidden = true
        }
        task.resume()
    }
}

extension FeedbackSlackViewController {
    func keyboardWillShow(notification: NSNotification) {
        let duration: NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.33
        let keyboardFrame: CGRect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRect.zero
        self.view.layoutIfNeeded()
        self.topConstraint.constant = self.defaultTopConstraint - keyboardFrame.size.height
        UIView.animateWithDuration(duration) { [unowned self] in
            self.view.setNeedsLayout()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        let duration: NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.33
        self.view.layoutIfNeeded()
        self.topConstraint.constant = self.defaultTopConstraint
        UIView.animateWithDuration(duration) { [unowned self] in
            self.view.setNeedsLayout()
        }
    }
}

extension FeedbackSlackViewController {
    func imageViewTapGestureRecognizer(gesture: UITapGestureRecognizer) {

        if let video: NSURL = self.video {
            let mediaPlayerViewController: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: video)
            self.presentViewController(mediaPlayerViewController, animated: true, completion: nil)
        } else {
            let previewViewController: FeedbackPreviewViewController = FeedbackPreviewViewController.instantitate()
            previewViewController.image = self.image
            self.transition.presentDelegate = self
            self.transition.dismissDelegate = previewViewController
            previewViewController.transitioningDelegate = self.transition
            previewViewController.modalPresentationStyle = UIModalPresentationStyle.Custom

            self.presentViewController(previewViewController, animated: true, completion: nil)
        }
    }
}

extension FeedbackSlackViewController: FS_TransitionDelegate {
    func transitionRect(transition: FS_Transition) -> CGRect {
        self.imageView.layoutIfNeeded()
        return self.imageView.convertRect(self.imageView.bounds, toView: nil)
    }

    func transitionImage(transition: FS_Transition) -> UIImage? {
        return self.image
    }
}

extension FeedbackSlackViewController: FS_StoryboardInstantiatable {
    static var storyboardName: String {
        return "FeedbackSlackViewController"
    }
    static var storyboardIdentifier: String {
        return "feedbackSlackViewController"
    }
}
