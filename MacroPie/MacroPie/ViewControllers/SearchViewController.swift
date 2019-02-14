//
//  ViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/17/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {

	var didSelectFoodItem: ((FoodItemViewModel) -> Void)?
	
	let searchController = UISearchController(searchResultsController: nil)
	
	var searchViewModel = SearchViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Food Items"
		navigationItem.searchController = searchController
		
		navigationItem.title = "Search Food Database"
		
		definesPresentationContext = true
		
		searchViewModel.didUpdateItems = {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
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
		return searchViewModel.items?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath) as? FoodItemCell
		
		cell?.foodItemName?.text = searchViewModel.getItemName(at: indexPath.row)
		cell?.foodItemDescription?.text = searchViewModel.getItemDescription(at: indexPath.row)
		searchViewModel.getItemCalories(at: indexPath.row) { (calories) in
			cell?.foodItemCalories?.text = calories
		}
		
		return cell!
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100.0
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let item = self.searchViewModel.items?[indexPath.row] else { return }
		didSelectFoodItem?(item)
	}
}

extension SearchViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchViewModel.didUpdateSearchText(with: searchController.searchBar.text)
	}
}
