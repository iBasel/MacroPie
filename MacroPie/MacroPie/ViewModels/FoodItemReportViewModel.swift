//
//  FoodItemReportViewModel.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/19/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit

private struct FoodItemReportsResultViewModel {
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

private struct FoodsViewModel {
	let food: FoodViewModel?
	
	init(foods: Foods) {
		self.food = FoodViewModel(food: foods.food)
	}
}

private struct FoodViewModel {
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

class FoodReportViewModel {
	let foodReportClient = FoodReportClient()
	
	var didGetFoodReport: ((_ nutrients: [NutrientsViewModel]?, _ label: String) -> Void)?
	var didGetEnergy: ((String) -> Void)?
	var failedToGetReport: ((String) -> Void)?
	private var macrosSet: Set = [NutrientIds.protein.rawValue, NutrientIds.carbs.rawValue, NutrientIds.fat.rawValue]
	
	private var nutrients: [NutrientsViewModel]? {
		didSet {
			nutrients?.forEach({ (nutrient) in
				print(nutrient.name, nutrient.value, nutrient.measures.first!)
			})
			
			var label = ""
			
			if let measure = nutrients?.first?.measures.first {
				label = String(describing: "in \(measure.quantity) \(measure.label)")
			}
			
			didGetFoodReport?(nutrients?.filter{ return (Double($0.value) ?? 0.0) > 0.0 }, label)
		}
	}
	
	private var energy: String? {
		didSet {
			if let energy = energy {
				didGetEnergy?("Calories: \(energy)")
			}
		}
	}
	
	func getApproximateCalories(nutrients: [NutrientsViewModel]) -> String{
		var total = 0.0
		nutrients.forEach { nutrient in
			switch nutrient.nutrientId {
			case NutrientIds.protein.rawValue:
				total += (Double(nutrient.value) ?? 0.0) * 4.0
				print(total)
			case NutrientIds.carbs.rawValue:
				total += (Double(nutrient.value) ?? 0.0) * 4.0
				print(total)
			case NutrientIds.fat.rawValue:
				total += (Double(nutrient.value) ?? 0.0) * 9.0
				print(total)
			default:
				total += 0.0
			}
		}
		return NSString(format: "%.2f", total) as String
	}
	
	func getReport(for foodItem: String?) {
		if let foodItem = foodItem {
			self.getReport(for: foodItem) { (nutrients) in
				self.nutrients = nutrients.filter{ return self.macrosSet.contains($0.nutrientId) }
				let energy = nutrients.filter{ return $0.nutrientId == NutrientIds.energy.rawValue }.first
				if let energy = energy {
					self.energy = energy.value
				} else {
					self.energy = self.getApproximateCalories(nutrients: self.nutrients!) //this can be force unwrapped becuase the value will be 0.0
				}
			}
		} else {
			failedToGetReport?("Data for report not found or missing")
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
		return "W2ceA0Nn2t5Sy6nDsGVSc15SaarVCkEyqpihsLRU"
	}
	
	func getQueryItems(appending items: [URLQueryItem]?) -> [URLQueryItem] {
		var queryItems = [URLQueryItem(name: "type", value: "b"),
						  URLQueryItem(name: "format", value: "json"),
						  URLQueryItem(name: "api_key", value: apiKey)]
		if let items = items {		
			queryItems.append(contentsOf: items)
		}
		return queryItems
	}
	
	func getReport(for foodItem: String?, completion: @escaping (([NutrientsViewModel]) -> Void)) {
		guard let foodItem = foodItem else { return }
		foodReportClient.getReport(from: self, for: foodItem) { (result) in
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
