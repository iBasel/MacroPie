//
//  ViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/17/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {

	let searchController = UISearchController(searchResultsController: nil)
	
	var searchViewModel = SearchViewModel()
	
	var items: [FoodItemViewModel]? {
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
		return items?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath)
		cell.textLabel?.text = items?[indexPath.row].name ?? ""
		return cell
	}	
}

extension SearchViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {			
			self.searchViewModel.searchItems(for: text) { [weak self] items in
				self?.items = items
			}
		}
	}
}
