//
//  AppDelegate.swift
//  LearnAutoLayout
//
//  Created by brown on 2022/4/23.
//

import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let tabvc = UITabBarController()
        
        tabvc.viewControllers = [ReviewViewController(), ChatViewController()]
        self.window?.rootViewController = tabvc
        self.window?.makeKeyAndVisible()
        return true
    }

}

