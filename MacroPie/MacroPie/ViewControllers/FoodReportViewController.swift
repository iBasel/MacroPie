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
	
	var foodItem: String?
	var didFinishReport: (() -> Void)?
	
	let foodItemReportViewModel = FoodReportViewModel()
	
	lazy var chartView: PieChartView = {
		let chartView = PieChartView()
		return chartView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		
		foodItemReportViewModel.didGetFoodReport = { [weak self] (nutrients, labelText) in
			let entries = nutrients?.map({ nutrient -> PieChartDataEntry in
				print(nutrient.name, nutrient.value, nutrient.measures.first!)
				return PieChartDataEntry(value: Double(nutrient.value) ?? 0, label: nutrient.name)
			})
			
			if let chartView = self?.chartView {
				self?.view.addSubview(chartView)
				chartView.translatesAutoresizingMaskIntoConstraints = false
				chartView.topAnchor.constraint(equalTo: (self?.view.topAnchor)!, constant: 100).isActive = true // it's self.view inside UIViewController so it's safe to force unwrape it
				chartView.leadingAnchor.constraint(equalTo: (self?.view.leadingAnchor)!).isActive = true
				chartView.trailingAnchor.constraint(equalTo: (self?.view.trailingAnchor)!).isActive = true
				chartView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
				
				let set = PieChartDataSet(values: entries, label: labelText)
				set.drawIconsEnabled = false
				set.colors = [.red, .green, .blue]
				
				let data = PieChartData(dataSet: set)
				self?.chartView.data = data
			}
		}
		
		foodItemReportViewModel.didGetEnergy = { [weak self] text in
			let label = UILabel()
			label.text = text
			label.textAlignment = .center
			self?.view.addSubview(label)
			
			label.translatesAutoresizingMaskIntoConstraints = false
			label.topAnchor.constraint(equalTo: self?.chartView.bottomAnchor ?? (self?.view.topAnchor)!, constant: 50).isActive = true
			label.leadingAnchor.constraint(equalTo: (self?.view.leadingAnchor)!).isActive = true
			label.trailingAnchor.constraint(equalTo: (self?.view.trailingAnchor)!).isActive = true
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
			foodItemReportViewModel.getReport(for: foodItem)
		}
	}
}
