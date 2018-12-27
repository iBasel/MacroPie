//
//  SearchListViewModelTests.swift
//  MacroPieTests
//
//  Created by Basel Abdelaziz on 12/27/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import XCTest

@testable import MacroPie

class SearchListViewModelTests: XCTestCase {
	
	func testSearchItem() {
		let searchViewModel = SearchViewModel()
		searchViewModel.searchItems(for: "Quest") { (foodItems) in
			XCTAssert(foodItems.count > 0)
		}
	}
}
