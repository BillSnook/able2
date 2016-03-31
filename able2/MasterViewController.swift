//
//  MasterViewController.swift
//  able2
//
//  Created by William Snook on 3/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var appDelegate: AppDelegate?
    
    var bleList = [BLEView]()
    
    var centralVC: UIViewController?
    var peripheralVC: UIViewController?

    @IBOutlet weak var arenaView: UIView!
    @IBOutlet weak var bleView: BLEView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        bleView.frame.origin = CGPoint(x: 10.0, y: 20.0)
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        managedObjectContext = appDelegate!.managedObjectContext
        print( "MasterViewController, viewDidLoad, managedObjectContext: \(managedObjectContext)")
        
        if let centralNavVC = splitViewController?.viewControllers[1] as? UINavigationController {
            centralVC = centralNavVC.topViewController
        }
        peripheralVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("setupPeripheral")

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for nextView in bleList {
            nextView.stopPing()
            nextView.removeFromSuperview()
        }
        bleList.removeAll()
        
        let bleSize = CGFloat(100.0)
        let width = arenaView.bounds.size.width - bleSize // Nominally 100 x 100 pixels
        let height = arenaView.bounds.size.height - bleSize
        for _ in 0...5 {    // Add ping views
            let xOrigin = CGFloat(BLEView.randomNumber(0..<Int(width)))
            let yOrigin = CGFloat(BLEView.randomNumber(0..<Int(height)))
            let xSize = bleSize + CGFloat(BLEView.randomNumber(-20..<20))
            let ySize = bleSize + CGFloat(BLEView.randomNumber(-20..<20))
            let bleViewNext = BLEView( frame: CGRect(x: xOrigin, y: yOrigin, width: xSize, height: ySize ) )
            let nextColor = UIColor( red: CGFloat(BLEView.randomNumber(128...255))/CGFloat( 256.0), green: CGFloat(BLEView.randomNumber(0...127))/CGFloat( 256.0), blue: CGFloat(BLEView.randomNumber(0...127))/CGFloat( 256.0), alpha: CGFloat( 1.0 ) )
            bleViewNext.backgroundColor = UIColor.clearColor()
            bleViewNext.initialColor = nextColor
            bleList.append(bleViewNext)
            arenaView.addSubview(bleViewNext)
        }

        // Remove when testing to keep it simple
//        for nextView in bleList {
//            nextView.startPing()
//        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        for nextView in bleList {
            nextView.stopPing()
            nextView.removeFromSuperview()
        }
        bleList.removeAll()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCentralDetail" {
            NSLog( "showCentralDetail" )
            appDelegate?.setDetailViewController( centralVC! )
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
//                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
        } else {
            if segue.identifier == "showPeripheralDetail" {
                NSLog( "showPeripheralDetail" )
                appDelegate?.setDetailViewController( peripheralVC! )
            }
        }
    }

}

