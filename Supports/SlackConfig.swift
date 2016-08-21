//
//  SlackConfig.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/20.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

public struct SlackConfig {
    public let token: String
    public static let shared: SlackConfig = SlackConfig()
    private init() {
        self.token = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("SlackConfig", ofType: "plist")!)!["SlackToken"] as! String
    }
}