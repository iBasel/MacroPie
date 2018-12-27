//
//  FoodReportViewModelTests.swift
//  FoodReportViewModelTests
//
//  Created by Basel Abdelaziz on 12/23/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import XCTest

@testable import MacroPie

class FoodReportViewModelTests: XCTestCase {

	func testApproximateCalories() {
		
		let measures = Measures(label: "", equivalent: 0.0, equivalentUnit: "", quantity: 0.0, value: "")
		
		let proteinNutrients = Nutrients(nutrientId: NutrientIds.protein.rawValue, name: "protein", derivation: "", group: "", unit: "", value: "25", measures: [measures])
		let protein = NutrientsViewModel(nutrients: proteinNutrients)
		
		let carbsNutrients = Nutrients(nutrientId: NutrientIds.carbs.rawValue, name: "carbs", derivation: "", group: "", unit: "", value: "50", measures: [measures])
		let carbs = NutrientsViewModel(nutrients: carbsNutrients)
		
		let fatNutrients = Nutrients(nutrientId: NutrientIds.fat.rawValue, name: "fat", derivation: "", group: "", unit: "", value: "9", measures: [measures])
		let fat = NutrientsViewModel(nutrients: fatNutrients)
		
		let foodReportViewModel = FoodReportViewModel()
		let approximateCalories = foodReportViewModel.getApproximateCalories(nutrients: [protein, carbs, fat])
		
		XCTAssertEqual(approximateCalories, "381.00")
	}
	
	func testReport() {
		let foodReportViewModel = FoodReportViewModel()
		let energyExpectation = expectation(description:"energyReport")
		
		foodReportViewModel.didGetEnergy = { energy in
			XCTAssertEqual(energy, "Calories: 500")
			energyExpectation.fulfill()
		}
		
		foodReportViewModel.getReport(for: "45153778")
		
		waitForExpectations(timeout: 30) { error in
			if let error = error {
				print("Error: \(error.localizedDescription)")
			}
		}
	}

}
