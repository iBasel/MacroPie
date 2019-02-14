//
//  SearchViewModel.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/18/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

private struct SearchListViewModel {
	let searchTerm: String?
	let start: Int?
	let end: Int?
	let total: Int?
	let sort: String?
	let foodGroup: String?
	let foodItems: [FoodItemViewModel]?
	
	init(foodItemsSearchList: FoodItemsSearchList) {
		self.searchTerm = foodItemsSearchList.searchTerm
		self.start = foodItemsSearchList.start
		self.end = foodItemsSearchList.end
		self.total = foodItemsSearchList.total
		self.sort = foodItemsSearchList.sort
		self.foodGroup = foodItemsSearchList.foodGroup
		self.foodItems = foodItemsSearchList.foodItems.map { return FoodItemViewModel(foodItem: $0) }
	}
}

class FoodItemViewModel {
	let offset: Int?
	let group: String?
	let name: String?
	let ndbno: String?
	let dataSource: String?
	let manufacturer: String?
	var energy: Int?
	var inHealthApp: Bool = false

	init(foodItem: FoodItem) {
		self.offset = foodItem.offset
		self.group = foodItem.group
		self.name = foodItem.name
		self.ndbno = foodItem.ndbno
		self.dataSource = foodItem.dataSource
		self.manufacturer = foodItem.manufacturer
	}
}

class SearchViewModel {
	var didUpdateItems: (() -> Void)?
	private var pendingRequestWorkItem: DispatchWorkItem?
	
	let searchClient = SearchClient()
	
	var items: [FoodItemViewModel]? {
		didSet {
			didUpdateItems?()
		}
	}
	
	func didUpdateSearchText(with text: String?) {
		if let text = text {
			self.searchItems(for: text) { [weak self] items in
				self?.items = items
			}
		}
	}
	
	func getItemName(at index: Int) -> String {
		return items?[index].name ?? ""
	}
	
	func getItemDescription(at index: Int) -> String {
		return items?[index].manufacturer ?? ""
	}
	
	func getItemCalories(at index: Int, completion: @escaping (String) -> Void) {
		
		let foodReportViewModel = FoodReportViewModel()
		foodReportViewModel.getReport(for: items?[index].ndbno)
		
		foodReportViewModel.didGetEnergy = { energy in
			if let energy = Int(energy) {
				self.items?[index].energy = energy
				completion(String(describing: energy))
			}
		}
	}
}

extension SearchViewModel: Endpoint {
	var base: String {
		return "https://api.nal.usda.gov"
	}
	
	var path: String {
		return "/ndb/search/"
	}
	
	var apiKey: String {
		return "W2ceA0Nn2t5Sy6nDsGVSc15SaarVCkEyqpihsLRU"
	}
	
	func getQueryItems(appending items: [URLQueryItem]?) -> [URLQueryItem] {
		var queryItems = [URLQueryItem(name: "format", value: "json"),
						  URLQueryItem(name: "sort", value: "n"),
						  URLQueryItem(name: "max", value: "25"),
						  URLQueryItem(name: "offset", value: "0"),
						  URLQueryItem(name: "api_key", value: apiKey)]
		if let items = items {
			queryItems.append(contentsOf: items)
		}
		return queryItems
	}
	

	func searchItems(for searchText: String, completion: @escaping (([FoodItemViewModel]) -> Void)) {		
		if searchText.count > 3 {
			pendingRequestWorkItem?.cancel()
			let requestWorkItem = DispatchWorkItem { [weak self] in
				self?.searchClient.searchTerm(from: self!, for: searchText) { (result) in
					switch result {
					case .success(let searchResult):
						
						guard let searchResultItems = searchResult?.list.foodItems else { return }
						let foodItems = searchResultItems.map { return FoodItemViewModel(foodItem: $0) }
						completion(foodItems)
					case .failure(let error):
						print("the error \(error)")
					}
				}
			}
			pendingRequestWorkItem = requestWorkItem
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: requestWorkItem)
		}
	}
}

