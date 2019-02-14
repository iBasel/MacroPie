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
		
		tableView.register(UINib(nibName: "FoodItemCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(add))
		
		self.tableView.delegate = nil
		self.tableView.dataSource = nil
		
		self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
		
		foodJournalViewModel?.totalEnergy.asObservable()
			.subscribe(onNext: { (totalEnergy) in
				self.navigationItem.title = String(describing: "Calories: \(Int(totalEnergy))")
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
			.bind(to: tableView.rx.items) { tableView, row, item in
				let indexPath = IndexPath(row: row, section: 0)

				let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? FoodItemCell

				cell?.foodItemName.text = item.name
				cell?.foodItemDescription.text = item.manufacturer
				cell?.foodItemCalories.text = String(describing: item.energy ?? 0)
				
				return cell!
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
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100.0
	}

}
