//
//  RecordingWindow.swift
//  SlackTest
//
//  Created by Kazuya Ueoka on 2016/09/07.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

protocol RecordingViewDelegate: class {
    func recordingViewDidTapped(recordingView: RecordingView) -> Void
}

class RecordingView: UIWindow {
    lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(RecordingView.tapGestureReceived(_:)))
    }()

    lazy var recordingLabel: UILabel = {
        let label: UILabel = UILabel(frame: self.bounds)
        label.font = UIFont(name: "Avenir-Heavy", size: 9.0)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.text = "Recording..."
        return label
    }()

    weak var delegate: RecordingViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self._recordingViewCommonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._recordingViewCommonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.recordingLabel.frame = self.bounds
    }

    private func _recordingViewCommonInit() {
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.redColor()
        self.windowLevel = UIWindowLevelStatusBar + 100
        self.addSubview(self.recordingLabel)
        self.addGestureRecognizer(self.tapGesture)
    }

    override func makeKeyAndVisible() {
        super.makeKeyAndVisible()

        self.alpha = 0.0
        UIView.animateWithDuration(0.33) { [unowned self] in
            self.alpha = 1.0
        }
    }

    func tapGestureReceived(tapGesture: UITapGestureRecognizer) {
        self.delegate?.recordingViewDidTapped(self)
    }
}
