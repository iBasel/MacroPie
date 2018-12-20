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
	var apiKey: String { get }
	func getQueryItems(appending items: [URLQueryItem]) -> [URLQueryItem]
}

extension Endpoint {
	
	func urlComponents(appending sequence: [URLQueryItem]?) -> URLComponents {
		var components = URLComponents(string: base)!
		components.path = path
		
		if let sequence = sequence {
			components.queryItems?.append(contentsOf: sequence)
		}
		
		return components
	}	
	
	func getRequest(appending sequence: [URLQueryItem]?) -> URLRequest {
		let url = urlComponents(appending: sequence).url!
		return URLRequest(url: url)
	}
}
