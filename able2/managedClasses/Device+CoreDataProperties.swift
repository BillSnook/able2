//
//  Device+CoreDataProperties.swift
//  able2
//
//  Created by William Snook on 6/28/16.
//  Copyright © 2016 William Snook. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Device {

    @NSManaged var name: String?
    @NSManaged var uuid: String?
    @NSManaged var services: NSOrderedSet?

}
