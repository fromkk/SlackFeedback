//
//  Instantiatable.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

protocol FS_StoryboardInstantiatable {
    static var storyboardName: String { get }
    static var storyboardIdentifier: String { get }
}

extension FS_StoryboardInstantiatable where Self: UIViewController {
    static func instantitate() -> Self {
        guard let viewController = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: Self.self)).instantiateViewControllerWithIdentifier(storyboardIdentifier) as? Self else {
            fatalError("storyboardName(\(storyboardName)) identifier(\(storyboardIdentifier)) is not found")
        }
        return viewController
    }
}
