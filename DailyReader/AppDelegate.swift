//
//  AppDelegate.swift
//  DailyReader
//
//  Created by Rain Qian on 2019/10/4.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [UINavigationController(rootViewController: ViewController(style: .plain)),
    UINavigationController(rootViewController: AttitudesTableViewController(style: .plain))]
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
    return true
  }


}

