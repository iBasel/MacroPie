//
//  FoodJournalViewModel.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 1/13/19.
//  Copyright © 2019 Basel Abdelaziz. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift

class FoodJournalViewModel {
	private let healthStore = HKHealthStore()
	private let disposeBag = DisposeBag()

	var foodItems: Variable<[FoodItemViewModel]> = Variable([])
	var totalEnergy: Variable<Double> = Variable(0.0)

	convenience init(foodItems: Variable<[FoodItemViewModel]>) {
		self.init()
		self.foodItems = foodItems
		
		self.foodItems.asObservable()
			.subscribe(onNext: { (foodItems) in
				// save to core data and health store
				for foodItem in foodItems {
					if let name = foodItem.name, let energy = foodItem.energy {
						self.addFoodItem(energy: energy, name: name)
						self.totalEnergy.value += energy
					}
				}
			})
			.disposed(by: disposeBag)
		
		setupHealthStore()
	}
	
	func setupHealthStore() {
		if HKHealthStore.isHealthDataAvailable() {
			if let quantitiyType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) {
				let readWriteDataTypes: Set<HKSampleType> = Set(arrayLiteral: quantitiyType)
				healthStore.requestAuthorization(toShare: readWriteDataTypes, read: readWriteDataTypes) { (success, error) in
					if !success {
						print("You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: \(String(describing: error?.localizedDescription)). If you're using a simulator, try it on a device.");
						return
					}
					
					DispatchQueue.main.async {
						self.fetchFoodItems()
					}
				}
			}
		}
	}
	
	func fetchFoodItems() {
		let calendar = NSCalendar.current
		
		let now = Date.init()
		
		let components = calendar.dateComponents(Set(arrayLiteral: .year, .month, .day), from: now)
		
		guard let  startDate = calendar.date(from: components) else { return }
		guard let foodType = HKObjectType.correlationType(forIdentifier: .food) else { return }

		let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
		let  predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
		
		let sampleQuere = HKSampleQuery(sampleType: foodType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
			if error != nil {
				print("An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: \(String(describing: error?.localizedDescription)).")
				return
			}
			
			guard let results = results else {
				print("An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: \(String(describing: error?.localizedDescription)).")
				return
			}
			
			results.forEach({ (correlation) in
				if let foodCorrelation = correlation as? HKCorrelation {
					self.correlationToFoodItem(foodCorrelation: foodCorrelation)
				}
			})
		}
		
		healthStore.execute(sampleQuere)
	}
	
	func correlationToFoodItem(foodCorrelation: HKCorrelation) {
		let name = foodCorrelation.metadata?[HKMetadataKeyFoodType]
		
		guard let energyConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else { return }
		
		let energyConsumedSamples = foodCorrelation.objects(for: energyConsumedType)

		energyConsumedSamples.forEach { (sample) in
			guard let energyConsumedSample = sample as? HKQuantitySample else { return }
			
			let energyQuantityConsumed = energyConsumedSample.quantity
			
			let energy = energyQuantityConsumed.doubleValue(for: HKUnit.kilocalorie())
			
			DispatchQueue.main.async {				
				self.totalEnergy.value += energy
			}
			
			print("\(String(describing: name)): \(energy)")
		}
	}
	
	func addFoodItem(energy: Double, name: String) {
		guard let foodItemCorrelation = foodItemToCorrelation(energy: energy, name: name) else { return }
		healthStore.save(foodItemCorrelation) { (success, error) in
			print("saved item in health app successfully")
		}
	}
	
	func foodItemToCorrelation(energy: Double, name: String) -> HKCorrelation? {
		
		guard let energyConsumedType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed) else { return nil }
		guard let foodType = HKObjectType.correlationType(forIdentifier: .food) else { return nil }

		let energyQuantityConsumed = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energy)
		let now = Date.init()
		
		let energyConsumedSample = HKQuantitySample(type: energyConsumedType, quantity: energyQuantityConsumed, start: now, end: now)
		let energyConsumedSamples = Set(arrayLiteral: energyConsumedSample)

		let foodCorrelationMetadata = [HKMetadataKeyFoodType: name]
		
		let foodItemCorrelation = HKCorrelation(type: foodType, start: now, end: now, objects: energyConsumedSamples, metadata: foodCorrelationMetadata)
		
		return foodItemCorrelation
	}
}
