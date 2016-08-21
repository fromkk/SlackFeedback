//
//  FeedbackSlackViewController.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit
import CoreTelephony

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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subjectField: FSSelectionField!
    @IBOutlet weak var commentView: FSTextView!
    @IBOutlet weak var indicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultTopConstraint = self.topConstraint.constant
        self.imageView.image = self.image

        if let path: String = NSBundle(forClass: self.dynamicType).pathForResource("FeedbackSlack", ofType: "plist"),
            items: [String] = NSDictionary(contentsOfFile: path)?.objectForKey("subjects") as? [String] {
            self.subjectField.items = items
        }

        self.commentView.layer.borderWidth = 1.0
        self.commentView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        self.commentView.layer.cornerRadius = 3.0
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
            image: UIImage = self.image,
            data: NSData = UIImagePNGRepresentation(image),
            appName: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String
            else {
            return
        }

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.systemLocale()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date: String = dateFormatter.stringFromDate(NSDate())

        let fileUpload: FileUpload = FileUpload(token: slack.slackToken, data: data, filename: "\(NSDate().timeIntervalSince1970).png", contentType: "image/png", title: "\(appName) feedback \(date)", initialComment: comment, channels: [slack.slackChannel])

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

extension FeedbackSlackViewController: FS_StoryboardInstantiatable {
    static var storyboardName: String {
        return "FeedbackSlackViewController"
    }
    static var storyboardIdentifier: String {
        return "feedbackSlackViewController"
    }
}
