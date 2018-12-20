//
//  SearchClient.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/18/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

class SearchClient: APIClient {
	var session: URLSession
	
	init(configuration: URLSessionConfiguration) {
		self.session = URLSession(configuration: configuration)
	}
	
	convenience init() {
		self.init(configuration: .default)
	}
	
	func searchTerm(from model: SearchViewModel, for term: String, completion: @escaping (Result<FoodItemsSearchResult?, APIError>) -> Void) {
		fetch(with: model.getRequest(appending: [URLQueryItem(name: "q", value: term)]), decode: { (json) -> FoodItemsSearchResult? in
			guard let searchResult = json as? FoodItemsSearchResult else { return  nil }
			return searchResult
		}, completion: completion)
	}
}
