//
//  SearchFoodItemsCoordinatorTests.swift
//  MacroPieTests
//
//  Created by Basel Abdelaziz on 12/27/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import XCTest

@testable import MacroPie

class SearchFoodItemsCoordinatorTests: XCTestCase {
	
	var searchFoodItemsCoordinator: SearchFoodItemsCoordinator?
	
	override func setUp() {
		let navController = UINavigationController()
		searchFoodItemsCoordinator = SearchFoodItemsCoordinator(navigationViewController: navController)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testCoordinatorSetup() {
		XCTAssertNotNil(searchFoodItemsCoordinator?.navigationViewController)
	}
	
	func testCoordinatorStart() {
		searchFoodItemsCoordinator?.start()
		XCTAssert(searchFoodItemsCoordinator?.navigationViewController.viewControllers.last?.isKind(of: SearchViewController.self) ?? false)
	}
	
	func testCoordinatorFoodReport() {
		searchFoodItemsCoordinator?.showFoodReport(foodItem: "")
		XCTAssert(searchFoodItemsCoordinator?.navigationViewController.viewControllers.last?.isKind(of: FoodReportViewController.self) ?? false)
	}
}
