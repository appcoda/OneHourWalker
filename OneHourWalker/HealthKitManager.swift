//
//  HealthKitManager.swift
//  OneHourWalker
//
//  Created by Matthew Maher on 2/19/16.
//  Copyright © 2016 Matt Maher. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!) {
        
        // State the health data type(s) we want to read from HealthKit.
        let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!)
        
        // State the health data type(s) we want to write from HealthKit.
        let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!)
        
        // Just in case OneHourWalker makes its way to an iPad...
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        // Request authorization to read and/or write the specific data.
        healthKitStore.requestAuthorizationToShareTypes(healthDataToWrite, readTypes: healthDataToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success, error:error)
            }
        }
    }
    
    func getHeight(sampleType: HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        
        // Predicate for the height query
        let distantPastHeight = NSDate.distantPast() as NSDate
        let currentDate = NSDate()
        let lastHeightPredicate = HKQuery.predicateForSamplesWithStartDate(distantPastHeight, endDate: currentDate, options: .None)
        
        // Get the single most recent height
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let heightQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion(nil, queryError)
                    return
                }
                
                // Set the first HKQuantitySample in results as the most recent height.
                let lastHeight = results!.first
            
                if completion != nil {
                    completion(lastHeight, nil)
                }
        }
        
        // Time to execute the query.
        self.healthKitStore.executeQuery(heightQuery)
    }
    
    func saveDistance(distanceRecorded: Double, date: NSDate ) {
                
        // Set the quantity type to the running/walking distance.
        let distanceType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        // Set the unit of measurement to miles.
        let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: distanceRecorded)
        
        // Set the official Quantity Sample.
        let distance = HKQuantitySample(type: distanceType!, quantity: distanceQuantity, startDate: date, endDate: date)
        
        // Save the distance quantity sample to the HealthKit Store.
        healthKitStore.saveObject(distance, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print(error)
            } else {
                print("The distance has been recorded! Better go check!")
            }
        })
    }
}