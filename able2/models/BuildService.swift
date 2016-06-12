//
//  BuildService.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation

struct BuildService {
	
	var service: Service?
	var name: String?
	var uuid: String?
	var primary: Bool?
	var characteristics: NSArray?
	
	init( fromService: Service? ) {
		
		if fromService != nil {
			service = fromService
			name = service!.name
			uuid = service!.uuid
			primary = service!.primary?.boolValue
			characteristics = [BuildCharacteristic]()
		} else {
			service = nil
			name = ""
			uuid = ""
			primary = true
			characteristics = [BuildCharacteristic]()
		}
	}
	
	
	
}
