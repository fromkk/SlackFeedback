//
//  TextInput.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

@objc protocol FSTextInput: class {
    var closeButton: UIBarButtonItem { get }
    var toolbar: UIToolbar { get }
    func closeButtonDidTapped(button: UIBarButtonItem) -> Void
}
