//
//  FoodItemsSearchResult.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/17/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

struct FoodItemsSearchResult: Decodable {
	let list: FoodItemsSearchList
	
	enum CodingKeys: String, CodingKey {
		case list
	}
}

struct FoodItemsSearchList: Decodable {
	
	let searchTerm: String
	let start: Int
	let end: Int
	let total: Int
	let sort: String //requested sort order (r=relevance or n=name)
	let foodGroup: String
	let foodItems: [FoodItem]
	
	enum CodingKeys: String, CodingKey {
		case searchTerm = "q"
		case start
		case end
		case total
		case sort
		case foodGroup = "group"
		case foodItems = "item"
	}
}

struct FoodItem: Decodable {
	let offset: Int
	let group: String
	let name: String
	let ndbno: String
	let dataSource: String
	let manufacturer: String
	
	enum CodingKeys: String, CodingKey {
		case offset
		case group
		case name
		case ndbno
		case dataSource = "ds"
		case manufacturer = "manu"
	}
}
