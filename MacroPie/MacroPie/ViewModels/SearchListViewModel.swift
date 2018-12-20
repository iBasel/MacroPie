//
//  SearchViewModel.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/18/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation


class SearchViewModel {
	var didUpdateItems: (() -> Void)?
	private var pendingRequestWorkItem: DispatchWorkItem?

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
}

extension SearchViewModel: Endpoint {
	var base: String {
		return "https://api.nal.usda.gov"
	}
	
	var path: String {
		return "/ndb/search/"
	}
	
	var apiKey: String {
		return "api_key=W2ceA0Nn2t5Sy6nDsGVSc15SaarVCkEyqpihsLRU"
	}
	
	func getQueryItems(appending items: [URLQueryItem]) -> [URLQueryItem] {
		var queryItems = [URLQueryItem(name: "format", value: "json"),
						  URLQueryItem(name: "sort", value: "n"),
						  URLQueryItem(name: "max", value: "25"),
						  URLQueryItem(name: "offset", value: "0")]
		queryItems.append(contentsOf: items)
		return queryItems
	}
	

	func searchItems(for searchText: String, completion: @escaping (([FoodItemViewModel]) -> Void)) {
		if searchText.count > 3 {
			pendingRequestWorkItem?.cancel()
			let requestWorkItem = DispatchWorkItem {
				SearchClient().searchTerm(from: self, for: searchText) { (result) in
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

struct FoodItemViewModel {
	let offset: Int?
	let group: String?
	let name: String?
	let ndbno: String?
	let dataSource: String?
	let manufacturer: String?
	
	init(foodItem: FoodItem) {
		self.offset = foodItem.offset
		self.group = foodItem.group
		self.name = foodItem.name
		self.ndbno = foodItem.ndbno
		self.dataSource = foodItem.dataSource
		self.manufacturer = foodItem.manufacturer
	}
}

