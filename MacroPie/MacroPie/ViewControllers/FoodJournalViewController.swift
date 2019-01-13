//
//  FoodJournalViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 1/12/19.
//  Copyright © 2019 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit

class FoodJournalViewController: UITableViewController {
	var addNewItem: (() -> ())?
	var foodItems: [FoodItemViewModel]?
	let cellIdentifier = "SavedFoodItemCell"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(add))
	}
	
	@objc func add() {
		addNewItem?()
	}
}

// table view delegte & datasource
extension FoodJournalViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return foodItems?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		cell.textLabel?.text = foodItems?[indexPath.row].name
		return cell
	}
}
