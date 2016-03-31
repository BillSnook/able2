//
//  Peripheral+CoreDataProperties.swift
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

extension Peripheral {

    @NSManaged var connectable: Bool
    @NSManaged var mainUUID: String?
    @NSManaged var name: String?
    @NSManaged var rssi: Int16
    @NSManaged var sightings: NSSet?

}
