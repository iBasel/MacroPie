//
//  FoodItemReport.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/19/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

public enum NutrientIds: String, CaseIterable {
	case protein = "203"
	case fat = "204"
	case carbs = "205"
	case energy = "208"
}

struct FoodItemReportsResult: Decodable {
	let foods: [Foods]
	let count: Int
	let notfound: Int
	let api: Float
}

struct Foods: Decodable {
	let food: Food
}

struct Food: Decodable {
	let nutrients: [Nutrients]
}

struct Nutrients: Decodable {
	let nutrientId: String
	let name: String
	let derivation: String
	let group: String
	let unit: String
	let value: String
	let measures: [Measures]
	
	enum CodingKeys: String, CodingKey {
		case nutrientId = "nutrient_id"
		case name
		case derivation
		case group
		case unit
		case value		
		case measures
	}
}

struct Measures: Decodable {
	let label: String
	let equivalent: Float
	let equivalentUnit: String
	let quantity: Float
	let value: String
	
	enum CodingKeys: String, CodingKey {
		case label
		case equivalent = "eqv"
		case equivalentUnit = "eunit"
		case quantity = "qty"
		case value
	}
}
