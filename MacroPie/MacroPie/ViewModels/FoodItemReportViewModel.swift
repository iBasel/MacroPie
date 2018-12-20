//
//  FoodItemReportViewModel.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/19/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit


class FoodReportViewModel {
	var didGetFoodReport: ((_ energy: Float, _ protein: Float, _ carbs: Float, _ fat: Float) -> Void)?
	var nutrients: [NutrientsViewModel]? {
		didSet {
			
			print(nutrients?[0].measures[0].value ?? 0, nutrients?[0].measures[0].equivalentUnit ?? "")
			nutrients?.forEach({ (nutrient) in
				print(nutrient.name, nutrient.value)
			})
			
			if let protein = nutrients?.filter({ return $0.nutrientId == NutrientIds.protein.rawValue }).first,
				let carbs = nutrients?.filter({ return $0.nutrientId == NutrientIds.carbs.rawValue }).first,
				let fat = nutrients?.filter({ return $0.nutrientId == NutrientIds.fat.rawValue }).first,
				let energy = nutrients?.filter({ return $0.nutrientId == NutrientIds.energy.rawValue }).first {
				let energyValue = Float(energy.value) ?? 0
				let proteinValue = Float(protein.value) ?? 0
				let carbsValue = Float(carbs.value) ?? 0
				let fatValue = Float(fat.value) ?? 0
				didGetFoodReport?(energyValue, proteinValue, carbsValue, fatValue)
			}
		}
	}
	
	func getReport(for foodItem: String?) {
		if let foodItem = foodItem {
			self.getReport(for: foodItem) { (nutrients) in
				self.nutrients = nutrients.filter({ (nutrient) -> Bool in
					if nutrient.nutrientId == NutrientIds.protein.rawValue
						|| nutrient.nutrientId == NutrientIds.fat.rawValue
						|| nutrient.nutrientId == NutrientIds.carbs.rawValue
						|| nutrient.nutrientId == NutrientIds.energy.rawValue
					{
						return true
					} else {
						return false
					}
				})
			}
		}
	}
}

extension FoodReportViewModel: Endpoint {
	
	var base: String {
		return "https://api.nal.usda.gov"
	}
	
	var path: String {
		return "/ndb/V2/reports"
	}
	
	var apiKey: String {
		return "api_key=W2ceA0Nn2t5Sy6nDsGVSc15SaarVCkEyqpihsLRU"
	}
	
	func getQueryItems(appending items: [URLQueryItem]) -> [URLQueryItem] {
		var queryItems = [URLQueryItem(name: "type", value: "b"),
						  URLQueryItem(name: "format", value: "json")]
		queryItems.append(contentsOf: items)
		return queryItems
	}
	
	func getReport(for foodItem: String?, completion: @escaping (([NutrientsViewModel]) -> Void)) {
		guard let foodItem = foodItem else { return }
		FoodReportClient().getReport(from: self, for: foodItem) { (result) in
			switch result {
			case .success(let reportResult):
				guard let itemReport = reportResult else { return }
				let report = itemReport.foods[0].food.nutrients.map { return  NutrientsViewModel(nutrients: $0) }
				completion(report)
			case .failure(let error):
				print("the error \(error)")
			}
		}
	}
	
}

struct FoodItemReportsResultViewModel {
	let foods: [FoodsViewModel]?
	let count: Int?
	let notfound: Int?
	let api: Float?
	
	init(foodItemReportsResult: FoodItemReportsResult) {
		self.foods = foodItemReportsResult.foods.map { return FoodsViewModel(foods: $0) }
		self.count = foodItemReportsResult.count
		self.notfound = foodItemReportsResult.notfound
		self.api = foodItemReportsResult.api
	}
}

struct FoodsViewModel {
	let food: FoodViewModel?
	
	init(foods: Foods) {
		self.food = FoodViewModel(food: foods.food)
	}
}

struct FoodViewModel {
	let nutrients: [NutrientsViewModel]?
	
	init(food: Food) {
		self.nutrients = food.nutrients.map { return NutrientsViewModel(nutrients: $0)}
	}
}

struct NutrientsViewModel {
	let nutrientId: String
	let name: String
	let group: String
	let unit: String
	let value: String
	let derivation: String
	let measures: [MeasuresViewModel]
	
	init(nutrients: Nutrients) {
		self.nutrientId = nutrients.nutrientId
		self.name = nutrients.name
		self.group = nutrients.group
		self.unit = nutrients.unit
		self.value = nutrients.value
		self.derivation = nutrients.derivation
		self.measures = nutrients.measures.map { return MeasuresViewModel(measures: $0) }
	}
}

struct MeasuresViewModel {
	let label: String
	let equivalent: Float
	let equivalentUnit: String
	let quantity: Float
	let value: String
	
	init(measures: Measures) {
		self.label = measures.label
		self.equivalent = measures.equivalent
		self.equivalentUnit = measures.equivalentUnit
		self.quantity = measures.quantity
		self.value = measures.value
	}
}
