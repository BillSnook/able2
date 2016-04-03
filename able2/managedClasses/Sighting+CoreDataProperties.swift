//
//  Sighting+CoreDataProperties.swift
//  able2
//
//  Created by Bill Snook on 4/2/16.
//  Copyright © 2016 William Snook. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Sighting {

    @NSManaged var date: NSDate?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var rssi: NSNumber?
    @NSManaged var peripheral: Peripheral?

}
