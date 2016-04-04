//
//  Interrogator.swift
//  able2
//
//  Created by Bill Snook on 4/3/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import CoreBluetooth


class Interrogator: Scanner, CBPeripheralDelegate {
	
	static let sharedInterrogator = Interrogator()


	required init() {

		super.init()
		
		cbManager.delegate = self
		
		print( "Interrogator init" )
		
	}
	
	func startScan( forDevices deviceList: [CBUUID]? ) {
		
		// We may want to get duplicates
		//	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool: NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil]
		if ( .PoweredOn == cbManager.state ) && !scanRunning {
			if cbManager.isScanning {
				cbManager.stopScan()
				print( "Interrogator starting scanning" )
				resetScanList()
			}
			scanRunning = true
			cbManager.scanForPeripheralsWithServices( deviceList, options: nil )	// Search for specific services
		} else {
			print( "Scan requested but state wrong: \(cbManager.state)" )
		}
	}
	
	
	func startInterrogation( forDevices deviceList: [CBUUID]? ) {

//			if ( connectable ) {
//				if ( CBPeripheralStateDisconnected == perp.peripheral.state ) {
//					[activityIndicator startAnimating];
//					UIImage *img = [UIImage imageNamed: @"button_round_yellow_small.jpg"];
//					//			DLog( @"Image for 'button_round_yellow_small': %@", img );
//					connectionIndicator.image = img;
//					[centralManager connectPeripheral: perp.peripheral options: nil];
//				} else {
//					[activityIndicator stopAnimating];
//					if ( CBPeripheralStateConnected == perp.peripheral.state ) {
//						connectionIndicator.image = [UIImage imageNamed: @"button_round_green_small.jpg"];
//					} else {    // Else connecting or disconnecting
//						connectionIndicator.image = [UIImage imageNamed: @"button_round_yellow_small.jpg"];
//					}
//				}
//			} else {
//				[activityIndicator stopAnimating];
//				connectionIndicator.image = [UIImage imageNamed: @"button_round_red_small.jpg"];
//				DLog( @"Not Connectable" );
//			}
	}
	
	
	func stopInterrogation() {
		
		if ( .PoweredOn == cbManager.state ) {
//			if cbManager.isScanning {
//				print( "Stopping scanning" )
//				cbManager.stopScan()
//			}
//			scanRunning = false
		}
	}
	
	
	//  MARK - CBCentral Delegate methods
	
	
	override func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		
		print("\n\nInterrogator didDiscoverPeripheral, UUID: \(peripheral.identifier.UUIDString)\n\n" )
		
	}
	
	override func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		
		print("\n\nInterrogator didDisconnectPeripheral, UUID: \(peripheral.identifier.UUIDString)\n\n" )
		
	}
	
	
	//  MARK - CBPeripheral Delegate methods
	
	// Services were discovered
	func peripheral( peripheral: CBPeripheral, didDiscoverServices error: NSError? ) {
		
		print("Interrogator didDiscoverServices" )
		if error != nil {
			print( "Error discovering services: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		// Discover any included services and characteristics
		print( "Peripheral services discovered: \(peripheral.services)" )
		
		// Loop through the newly filled peripheral.services array, just in case there's more than one.
//		services!.removeAll()
//		for service in peripheral.services! {
//            print( "Service discovered: \(service.UUID.uuid2string)" )
//            abService *abServ = [[abService alloc] initWithName: advertName andID: [service.UUID uuid2string] andService: service]
//            [services addObject: abServ]
//            [peripheral discoverIncludedServices: nil forService: service]
////        [peripheral discoverCharacteristics: nil forService: service]
//		}
//		tableView.reloadData()
	}
	
	
	func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		print( "Interrogator didModifyServices" )
		
		for serv in invalidatedServices {
			print( "Invalidated service: \(serv)" )
		}
	}
	
	
	func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
		print("Interrogator didDiscoverIncludedServicesForService")
		
		if (error != nil) {
			print( "Error discovering included services: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		print("Included Services discovered: \(service.includedServices)" )
		// Loop through the newly filled peripheral.services array, just in case there's more than one.
//		for serv in services! {
////            if ( service.UUID.isEqual( serv.service.UUID ) ) {
////                serv.subservices = service.includedServices
////            }
//		}
//		self.tableView.reloadData()
		
	}
	
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		print("Interrogator didDiscoverCharacteristicsForService")
		
		if error != nil {
			print( "Error discovering characteristics: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		print( "Characteristics discovered: \(service.characteristics)" )
		// Loop through the newly filled peripheral.services array, just in case there's more than one.
//		for serv in services! {
////            if ( service.isEqual( serv.service ) ) {
////                serv.characteristics = [NSMutableArray arrayWithArray: service.characteristics]
////            }
//		}
//		self.tableView.reloadData()
		
	}
	
	

}