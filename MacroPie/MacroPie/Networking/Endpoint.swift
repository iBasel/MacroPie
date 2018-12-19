//
//  Endpoint.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/18/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

protocol Endpoint {
	var base: String { get }
	var path: String { get }
}

extension Endpoint {
	var apiKey: String {
		return "api_key=W2ceA0Nn2t5Sy6nDsGVSc15SaarVCkEyqpihsLRU&format=json&sort=n&max=25&offset=0"
	}
	
	func urlComponents(appending sequence: [URLQueryItem]) -> URLComponents {
		var components = URLComponents(string: base)!
		components.path = path
		components.query = apiKey
		components.queryItems?.append(contentsOf: sequence)
		return components
	}	
	
	func request(appending sequence: [URLQueryItem]) -> URLRequest {
		let url = urlComponents(appending: sequence).url!
		return URLRequest(url: url)
	}
}
