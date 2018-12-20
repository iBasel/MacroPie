//
//  FoodReportClient.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/19/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

class FoodReportClient: APIClient {
	var session: URLSession
	
	init(configuration: URLSessionConfiguration) {
		self.session = URLSession(configuration: configuration)
	}
	
	convenience init() {
		self.init(configuration: .default)
	}
	
	func getReport(from model: FoodReportViewModel, for foodItem: String, completion: @escaping (Result<FoodItemReportsResult?, APIError>) -> Void) {
		fetch(with: model.getRequest(appending: [URLQueryItem(name: "ndbno", value: foodItem)]), decode: { (json) -> FoodItemReportsResult? in
			guard let foodReportResult = json as? FoodItemReportsResult else { return nil }
			return foodReportResult
		}, completion: completion)
	}
}
