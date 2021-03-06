//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Taagoo'iMac on 15/2/5.
//  Copyright (c) 2015年 Razeware. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation




class LocationsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
        
        }()

    deinit {
      fetchedResultsController.delegate = nil
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NSFetchedResultsController.deleteCacheWithName("Locations")
        performFetch()
    }
    
    
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            fatalCoreDataError(error)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
       let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "LocationCell") as LocationCell
        
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
   
        cell.configureForLocation(location)

        return cell
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as UINavigationController
            
            let controller = navigationController.topViewController as LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
                controller.locationToEdit = location
            }
        }
        
    }
    

}



extension LocationsViewController:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
            didChangeObject anObject: AnyObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: NSFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {
        
        switch type {
            case .Insert:
                println("*** NSFetchedResultsChangeInsert (object)")
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                println("*** NSFetchedResultsChangeDelete (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation: .Fade)
            case .Update:
                println("*** NSFetchedResultsChangeUpdate (object)")
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as LocationCell
                let location = controller.objectAtIndexPath(indexPath!) as Location
                cell.configureForLocation(location)
            case .Move:
                println("*** NSFetchedResultsChangeMove (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!],withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController,
            didChangeSection sectionInfo:  NSFetchedResultsSectionInfo,
            atIndex sectionIndex: Int,
            forChangeType type: NSFetchedResultsChangeType) {
                
      switch type  {
                    
            case .Insert:
                println("*** NSFetchedResultsChangeInsert (section)")
                tableView.insertSections(NSIndexSet(index: sectionIndex),withRowAnimation: .Fade)
            case .Delete:
              println("*** NSFetchedResultsChangeDelete (section)")
              tableView.deleteSections(NSIndexSet(index: sectionIndex),withRowAnimation: .Fade)

            case .Update:
              println("*** NSFetchedResultsChangeUpdate (section)")

            case .Move:
              println("*** NSFetchedResultsChangeMove (section)")
      }

    }
}
