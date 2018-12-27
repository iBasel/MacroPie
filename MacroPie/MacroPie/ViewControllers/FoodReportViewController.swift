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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		
		foodItemReportViewModel.didGetFoodReport = { [weak self] (nutrients, labelText) in
			let entries = nutrients?.map({ nutrient -> PieChartDataEntry in
				print(nutrient.name, nutrient.value, nutrient.measures.first!)
				return PieChartDataEntry(value: Double(nutrient.value) ?? 0, label: nutrient.name)
			})
			
			let chartView = PieChartView(frame: CGRect(x: 0, y: 100, width: self?.view.frame.size.width ?? 400, height: 400))
			
			let set = PieChartDataSet(values: entries, label: labelText)
			set.drawIconsEnabled = false
			set.colors = [.red, .green, .blue]
			
			let data = PieChartData(dataSet: set)
			chartView.data = data
			
			self?.view.addSubview(chartView)
		}
		
		foodItemReportViewModel.didGetEnergy = { [weak self] text in
			let label = UILabel(frame: CGRect(x: 0, y: 500, width: 400, height: 100))
			label.text = text
			self?.view.addSubview(label)
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

extension FoodReportViewController: ChartViewDelegate {
	
}
