//
//  FoodItemCell.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 2/13/19.
//  Copyright © 2019 Basel Abdelaziz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class FoodItemCell: UITableViewCell {
	
	@IBOutlet weak var foodItemName: UILabel!
	@IBOutlet weak var foodItemDescription: UILabel!
	@IBOutlet weak var foodItemCalories: UILabel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}
