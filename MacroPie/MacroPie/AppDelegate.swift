//
//  AppDelegate.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/17/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let navController = UINavigationController()
		window?.rootViewController = navController
		
		let searchFoodItemsCoordinator: SearchFoodItemsCoordinator = SearchFoodItemsCoordinator(navigationViewController: navController)
		searchFoodItemsCoordinator.start()
		return true
	}
}

