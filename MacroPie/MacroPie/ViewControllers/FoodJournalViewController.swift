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
	
	private var foodJournalViewModel: FoodJournalViewModel?
	
	var addNewItem: (() -> ())?
	let cellIdentifier = "SavedFoodItemCell"
	
	private let disposeBag = DisposeBag()
	
	var didSelectFoodItem: ((FoodItemViewModel) -> Void)?
	
	convenience init(foodItems: Variable<[FoodItemViewModel]>) {
		self.init()
		foodJournalViewModel = FoodJournalViewModel(foodItems: foodItems)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(add))
		
		self.tableView.delegate = nil
		self.tableView.dataSource = nil

		foodJournalViewModel?.totalEnergy.asObservable()
			.subscribe(onNext: { (totalEnergy) in
				self.navigationItem.title = String(describing: "Total energy: \(totalEnergy)")
			})
			.disposed(by: disposeBag)
		
		bindTableView()	
		bindDidSelectTableView()
	}
	
	@objc func add() {
		addNewItem?()
	}
	
	func bindTableView() {
		foodJournalViewModel?.foodItems.asObservable()
			.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row, item, cell in
				cell.textLabel?.text = item.name
			}
			.disposed(by: disposeBag)
	}
	
	func bindDidSelectTableView() {
		tableView
			.rx
			.modelSelected(FoodItemViewModel.self)
			.subscribe(onNext :{ [weak self] foodItem in
				
				self?.didSelectFoodItem?(foodItem)
				
			})
			.disposed(by: disposeBag)
	}

}
