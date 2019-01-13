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
import RxSwift

class SearchFoodItemsCoordinator: Coordinator {
	
	var childCoordinators: [Coordinator] = []
	
	let navigationViewController: UINavigationController
	
	let foodItems = Variable<[FoodItemViewModel]>([])
	
	init(navigationViewController: UINavigationController) {
		self.navigationViewController = navigationViewController
	}
	
	func start() {
		showFoodJournal()
	}
	
	func showFoodJournal() {
		let foodJournalViewController = FoodJournalViewController()		
		foodJournalViewController.foodItems = foodItems
		self.navigationViewController.pushViewController(foodJournalViewController, animated: true)
		
		foodJournalViewController.addNewItem = {
			self.showSearchFoodItems()
		}
		
		foodJournalViewController.didSelectFoodItem = { foodItem in
			self.showFoodReport(foodItem: foodItem)
		}
	}
	
	func showSearchFoodItems() {
		guard let searchViewController = UIStoryboard.init(name: "Search", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
		self.navigationViewController.pushViewController(searchViewController, animated: true)
		
		searchViewController.didSelectFoodItem = { foodItem in
			self.showFoodReport(foodItem: foodItem)
		}
	}
	
	func showFoodReport(foodItem: FoodItemViewModel) {
		let foodReportViewController = FoodReportViewController()
		foodReportViewController.foodItem = foodItem
		self.navigationViewController.pushViewController(foodReportViewController, animated: true)
		
		foodReportViewController.didFinishReport = {
			self.navigationViewController.popViewController(animated: true)
		}
		
		foodReportViewController.didSaveItem = { foodItem in
			self.foodItems.value.append(foodItem)
			self.navigationViewController.popToRootViewController(animated: true)
		}
	}
}
