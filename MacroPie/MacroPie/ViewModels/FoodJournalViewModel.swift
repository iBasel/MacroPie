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
	var totalEnergy: Variable<Int> = Variable(0)

	convenience init(foodItems: Variable<[FoodItemViewModel]>) {
		self.init()
		self.foodItems = foodItems

		setupHealthStore()

		self.foodItems.asObservable()			
			.subscribe(onNext: { (foodItems) in
				// save to core data and health store
				foodItems.filter({ (foodItem) -> Bool in
					return !foodItem.inHealthApp
				}).forEach({ (foodItem) in
					if let name = foodItem.name, let energy = foodItem.energy, let ndbno = foodItem.ndbno {
						self.addFoodItem(energy: energy, name: name, ndbno: ndbno)
						self.totalEnergy.value += energy
					}
				})
			})
			.disposed(by: disposeBag)
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
				print("An error occured fetching the user's tracked food. The error was: \(String(describing: error?.localizedDescription)).")
				return
			}
			
			guard let results = results else {
				print("An error occured fetching the user's tracked food. The error was: \(String(describing: error?.localizedDescription)).")
				return
			}
			
			results.forEach({ (correlation) in
				if let foodCorrelation = correlation as? HKCorrelation {
					self.correlationToFoodItem(foodCorrelation: foodCorrelation) { foodItemViewModel in
						DispatchQueue.main.async {
							self.foodItems.value.append(foodItemViewModel)
							self.totalEnergy.value += foodItemViewModel.energy ?? 0
						}
					}
				}
			})
		}
		
		healthStore.execute(sampleQuere)
	}
	
	func correlationToFoodItem(foodCorrelation: HKCorrelation, completion: (FoodItemViewModel) -> Void) {
		guard let ndbno = foodCorrelation.metadata?[HKMetadataKeyExternalUUID] as? String, let name = foodCorrelation.metadata?[HKMetadataKeyFoodType] as? String else { return }
		guard let energyConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else { return }
		
		let energyConsumedSamples = foodCorrelation.objects(for: energyConsumedType)

		energyConsumedSamples.forEach { (sample) in
			guard let energyConsumedSample = sample as? HKQuantitySample else { return }
			
			let energyQuantityConsumed = energyConsumedSample.quantity
			
			let energy = Int(energyQuantityConsumed.doubleValue(for: HKUnit.kilocalorie()))
			
			let foodItem = FoodItem(name: name, ndbno: ndbno)
			let foodItemViewModel = FoodItemViewModel(foodItem: foodItem)
			foodItemViewModel.energy = energy
			foodItemViewModel.inHealthApp = true
			
			completion(foodItemViewModel)
		}
	}
	
	func addFoodItem(energy: Int, name: String, ndbno: String) {
		guard let foodItemCorrelation = foodItemToCorrelation(energy: energy, name: name, ndbno: ndbno) else { return }
		healthStore.save(foodItemCorrelation) { (success, error) in
			print("saved item in health app successfully")
		}
	}
	
	func foodItemToCorrelation(energy: Int, name: String, ndbno: String) -> HKCorrelation? {
		
		guard let energyConsumedType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed) else { return nil }
		guard let foodType = HKObjectType.correlationType(forIdentifier: .food) else { return nil }

		let energyQuantityConsumed = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: Double(energy))
		let now = Date.init()
		
		let energyConsumedSample = HKQuantitySample(type: energyConsumedType, quantity: energyQuantityConsumed, start: now, end: now)
		let energyConsumedSamples = Set(arrayLiteral: energyConsumedSample)

		let foodCorrelationMetadata = [HKMetadataKeyFoodType: name, HKMetadataKeyExternalUUID: ndbno]
		
		let foodItemCorrelation = HKCorrelation(type: foodType, start: now, end: now, objects: energyConsumedSamples, metadata: foodCorrelationMetadata)
		
		return foodItemCorrelation
	}
}
