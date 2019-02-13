//
//  FoodReportViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/19/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit
import Charts

class FoodReportViewController: UIViewController {
	
	var foodItem: FoodItemViewModel?
	var didFinishReport: (() -> Void)?
	var didSaveItem: ((FoodItemViewModel) -> Void)?
	
	let foodItemReportViewModel = FoodReportViewModel()
	
	lazy var chartView: PieChartView = {
		let chartView = PieChartView()
		return chartView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItem))
		
		foodItemReportViewModel.didGetFoodReport = { [weak self] (nutrients, labelText) in
			let entries = nutrients?.map({ nutrient -> PieChartDataEntry in
				print(nutrient.name, nutrient.value, nutrient.measures.first!)
				return PieChartDataEntry(value: Double(nutrient.value) ?? 0, label: nutrient.name)
			})
			
			if let chartView = self?.chartView {
				self?.view.addSubview(chartView)
				chartView.translatesAutoresizingMaskIntoConstraints = false
				chartView.topAnchor.constraint(equalTo: (self?.view.safeAreaLayoutGuide.topAnchor)!, constant: 20).isActive = true // it's self.view inside UIViewController so it's safe to force unwrape it
				chartView.leadingAnchor.constraint(equalTo: (self?.view.safeAreaLayoutGuide.leadingAnchor)!).isActive = true
				chartView.trailingAnchor.constraint(equalTo: (self?.view.safeAreaLayoutGuide.trailingAnchor)!).isActive = true
				chartView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
				
				let set = PieChartDataSet(values: entries, label: labelText)
				set.drawIconsEnabled = false
				set.colors = [.red, .green, .blue]
				
				let data = PieChartData(dataSet: set)
				self?.chartView.data = data
			}
		}
		
		foodItemReportViewModel.didGetEnergy = { [weak self] energy in
			
			//add energy to the food item
			self?.foodItem?.energy = Double(energy)
			
			let label = UILabel()
			label.text = "Calories: \(energy)"
			label.textAlignment = .center
			self?.view.addSubview(label)
			
			label.translatesAutoresizingMaskIntoConstraints = false
			label.topAnchor.constraint(equalTo: self?.chartView.bottomAnchor ?? (self?.view.topAnchor)!, constant: 50).isActive = true
			label.leadingAnchor.constraint(equalTo: (self?.view.safeAreaLayoutGuide.leadingAnchor)!).isActive = true
			label.trailingAnchor.constraint(equalTo: (self?.view.safeAreaLayoutGuide.trailingAnchor)!).isActive = true
			label.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
		}
		
		foodItemReportViewModel.failedToGetReport = { [weak self] error in
			let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
			let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
				self?.didFinishReport?()
			})
			alert.addAction(action)
			
			self?.present(alert, animated: true, completion: nil)
		}
		
		assert(foodItem != nil, "Food Item not set")
		
		if let foodItem = foodItem {
			foodItemReportViewModel.getReport(for: foodItem.ndbno)
		}
	}
	
	@objc func saveItem() {
		guard let foodItem = foodItem else {
			didFinishReport?()
			return
		}
		
		didSaveItem?(foodItem)
	}
}
