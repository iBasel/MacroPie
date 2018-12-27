//
//  SearchFoodItemsCoordinator.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 11/29/18.
//  Copyright © 2018 MassIdeation. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchFoodItemsCoordinator: Coordinator {
	
	var childCoordinators: [Coordinator] = []
	
	let navigationViewController: UINavigationController
	
	init(navigationViewController: UINavigationController) {
		self.navigationViewController = navigationViewController
	}
	
	func start() {
		showSearchFoodItems()
	}
	
	func showSearchFoodItems() {
		guard let searchViewController = UIStoryboard.init(name: "Search", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
		self.navigationViewController.pushViewController(searchViewController, animated: true)
		
		searchViewController.didSelectFoodItem = { foodItem in
			self.showFoodReport(foodItem: foodItem)
		}
	}
	
	func showFoodReport(foodItem: String) {
		let foodReportViewController = FoodReportViewController()
		foodReportViewController.foodItem = foodItem
		self.navigationViewController.pushViewController(foodReportViewController, animated: true)
		
		foodReportViewController.didFinishReport = {
			self.navigationViewController.popViewController(animated: true)
		}
	}
}
