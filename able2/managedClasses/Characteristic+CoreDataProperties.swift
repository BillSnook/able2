//
//  Characteristic+CoreDataProperties.swift
//  able2
//
//  Created by William Snook on 7/26/16.
//  Copyright © 2016 William Snook. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Characteristic {

    @NSManaged var permissions: NSNumber?
    @NSManaged var properties: NSNumber?
    @NSManaged var uuid: String?
    @NSManaged var value: Data?
    @NSManaged var service: Service?

}
