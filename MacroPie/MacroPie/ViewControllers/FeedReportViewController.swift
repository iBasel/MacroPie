//
//  FeedReportViewController.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/19/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit

class FeedReportViewController: UIViewController {
	
	var foodItem: String?
	
	let foodItemReportViewModel = FoodReportViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		
		foodItemReportViewModel.didGetFoodReport = { [weak self] (energy, protein, carbs, fat) in
			let pieChartView = PieChartView()
			pieChartView.frame = CGRect(x: 0, y: 100, width: self?.view.frame.size.width ?? 400, height: 400)
			pieChartView.segments = [
				Segment(color: .blue, value: CGFloat(protein)),
				Segment(color: .green, value: CGFloat(carbs)),
				Segment(color: .yellow, value: CGFloat(fat))
			]
			self?.view.addSubview(pieChartView)
			
		}
		
		assert(foodItem != nil, "Food Item not set")
		
		if let foodItem = foodItem {
			foodItemReportViewModel.getReport(for: foodItem)
		}
	}
}
