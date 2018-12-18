//
//  ViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/17/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {

	let apiKey = "W2ceA0Nn2t5Sy6nDsGVSc15SaarVCkEyqpihsLRU"
	let searchController = UISearchController(searchResultsController: nil)
	
	var items: FoodItemsSearchResult? {
		didSet {
			DispatchQueue.main.async {				
				self.tableView.reloadData()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FoodItemCell")
		
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Food Items"
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if #available(iOS 11.0, *) {
			navigationItem.hidesSearchBarWhenScrolling = false
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if #available(iOS 11.0, *) {
			navigationItem.hidesSearchBarWhenScrolling = true
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items?.list.foodItems.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath)
		cell.textLabel?.text = items?.list.foodItems[indexPath.row].name ?? ""
		return cell
	}
	
	func getResults(for searchText: String) {
		guard let searchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
		
		let url = "https://api.nal.usda.gov/ndb/search/?format=json&q=\(searchText)&sort=n&max=25&offset=0&api_key=\(apiKey)"
		
		URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
			let result = String(data: data!, encoding: .utf8)
			if let result = result {
				if let resultData = result.data(using: .utf8) {
					do {
						if let items = try JSONDecoder().decode(FoodItemsSearchResult?.self, from: resultData) {
							self.items = items
						}
					} catch {
						print(error)
					}
				}
			}
			}.resume()
	}

}

extension SearchViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchController.searchResultsController?.view.isHidden = false
		if let text = searchController.searchBar.text, text.count > 3 {
			getResults(for: text)
		}
	}
}
