//
//  FoodJournalViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 1/12/19.
//  Copyright © 2019 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class FoodJournalViewController: UITableViewController {
	var addNewItem: (() -> ())?
	var foodItems: Variable<[FoodItemViewModel]> = Variable([])
	let cellIdentifier = "SavedFoodItemCell"
	
	private let disposeBag = DisposeBag()
	
	var didSelectFoodItem: ((FoodItemViewModel) -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(add))
		
		self.tableView.delegate = nil
		self.tableView.dataSource = nil

		foodItems.asObservable()
			.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row, item, cell in
				cell.textLabel?.text = item.name
			}.disposed(by: disposeBag)
	
		tableView
			.rx
			.modelSelected(FoodItemViewModel.self)
			.subscribe(onNext :{ [weak self] foodItem in
				
				self?.didSelectFoodItem?(foodItem)
				
			}).disposed(by: disposeBag)
	}
	
	@objc func add() {
		addNewItem?()
	}
}

// table view delegte & datasource
extension FoodJournalViewController {
//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return foodItems?.count ?? 0
//	}
//	
//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//		cell.textLabel?.text = foodItems?[indexPath.row].name
//		return cell
//	}
}
