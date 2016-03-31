//
//  Sighting+CoreDataProperties.swift
//  able2
//
//  Created by William Snook on 3/31/16.
//  Copyright © 2016 William Snook. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Sighting {

    @NSManaged var date: NSTimeInterval
    @NSManaged var latitude: Float
    @NSManaged var longitude: Float
    @NSManaged var rssi: Int16
    @NSManaged var peripheral: Peripheral?

}
