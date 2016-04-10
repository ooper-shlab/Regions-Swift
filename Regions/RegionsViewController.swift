//
//  RegionsViewController.swift
//  Regions
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/16.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This controller displays the map and allows the user to set regions to monitor.
 */

import UIKit
import MapKit
import CoreLocation

@objc(RegionsViewController)
class RegionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationBarDelegate {
    
    @IBOutlet var updatesTableView: UITableView!
    var locationManager: CLLocationManager!
    
    @IBOutlet private weak var regionsMapView: MKMapView!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    
    private var updateEvents: [String] = []
    
    //MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        self.locationManager.delegate = nil
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create empty array to add region events to.
        updateEvents = []
        
        // Create location manager early, so we can check and ask for location services authorization.
        locationManager = CLLocationManager()
        // Configure the location manager.
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Define a weak self reference.
        
        // Subscribe to app state change notifications, so we can stop/start location services.
        
        // When our app is interrupted, stop the standard location service,
        // and start significant location change service, if available.
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) {[weak self] note in
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // Stop normal location updates and start significant location change updates for battery efficiency.
                self?.locationManager.stopUpdatingLocation()
                self?.locationManager.startMonitoringSignificantLocationChanges()
            } else {
                NSLog("Significant location change monitoring is not available.")
            }
        }
        
        // Stop the significant location change service, if available,
        // and start the standard location service.
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue:nil) {[weak self] note in
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // Stop significant location updates and start normal location updates again since the app is in the forefront.
                self?.locationManager.stopMonitoringSignificantLocationChanges()
                self?.locationManager.startUpdatingLocation()
            } else {
                NSLog("Significant location change monitoring is not available.")
            }
            
            if !(self?.updatesTableView.hidden ?? false) {
                // Reload the updates table view to reflect update events that were recorded in the background.
                self?.updatesTableView.reloadData()
                
                // Reset the icon badge number to zero.
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Request always allowed location service authorization.
        // This is done here, so we can display an alert if the user has denied location services previously
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            // If status is not determined, then we should ask for authorization.
            self.locationManager.requestAlwaysAuthorization()
        } else if CLLocationManager.authorizationStatus() == .Denied {
            // If authorization has been denied previously, inform the user.
            NSLog("%s: location services authorization was previously denied by the user.", #function);
            
            // Display alert to the user.
            let alert = UIAlertController(title: "Location services", message: "Location services were previously denied by the user. Please enable location services for this app in settings.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .Default,
                                              handler: {action in}) // Do nothing action to dismiss the alert.
            
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else { // We do have authorization.
            // Start the standard location service.
            self.locationManager.startUpdatingLocation()
        }
        
        // Set the map's user tracking mode.
        self.regionsMapView.userTrackingMode = .None
        
        // Get all regions being monitored for this application.
        let regions = locationManager.monitoredRegions
        
        // Iterate through the regions and add annotations to the map for each of them.
        for region in regions where region is CLCircularRegion {
            let annotation = RegionAnnotation(CLCircularRegion: region as! CLCircularRegion)
            regionsMapView.addAnnotation(annotation)
        }
    }
    
    //MARK: - UITableViewDelegate
    
    // Return the number of section, which is one.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Return the number of rows in the one and only section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateEvents.count
    }
    
    // Dequeue and return a table view cell to be displayed in the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell!.textLabel!.text = updateEvents[indexPath.row]
        cell!.textLabel!.numberOfLines = 4
        
        return cell!
    }
    
    // Return the height we want for the table view cells.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    //MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let currentAnnotation = annotation as? RegionAnnotation {
            let annotationIdentifier = currentAnnotation.title!
            var regionView = regionsMapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as! RegionAnnotationView?
            
            if regionView == nil {
                regionView = RegionAnnotationView(annotation: currentAnnotation)
                regionView!.map = regionsMapView
                
                // Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
                let removeRegionButton = UIButton(type: .Custom)
                removeRegionButton.frame = CGRectMake(0.0, 0.0, 25.0, 25.0)
                removeRegionButton.setImage(UIImage(named: "RemoveRegion"), forState: .Normal)
                
                regionView!.leftCalloutAccessoryView = removeRegionButton
            } else {
                regionView!.annotation = currentAnnotation
                regionView!.theAnnotation = currentAnnotation
            }
            
            // Update or add the overlay displaying the radius of the region around the annotation.
            regionView!.updateRadiusOverlay()
            
            return regionView
        }
        
        return nil
    }
    
    // Return the map overlay that depicts the region.
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            // Create the view for the radius overlay.
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            
            return circleRenderer
        }
        
        fatalError("overlay needs to be an MKCircle")
    }
    
    // Enable the user to reposition the pins representing the regions by dragging them.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        guard let regionView = annotationView as? RegionAnnotationView else {
            return
        }
        let regionAnnotation = regionView.annotation as! RegionAnnotation
        
        // If the annotation view is starting to be dragged, remove the overlay and stop monitoring the region.
        if newState == .Starting {
            regionView.removeRadiusOverlay()
            
            locationManager.stopMonitoringForRegion(regionAnnotation.region!)
        }
        
        // Once the annotation view has been dragged and placed in a new location, update and add the overlay and begin monitoring the new region.
        if oldState == .Dragging && newState == .Ending {
            regionView.updateRadiusOverlay()
            
            let newRegion = CLCircularRegion(center: regionAnnotation.coordinate,
                                             radius: 1000.0,
                                             identifier: String(format: "%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude))
            
            regionAnnotation.region = newRegion
            
            locationManager.startMonitoringForRegion(regionAnnotation.region!)
        }
    }
    
    // The X was tapped on a region annotation, so remove that region form the map, and stop monitoring that region.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let regionView = view as! RegionAnnotationView
        let regionAnnotation = regionView.annotation as! RegionAnnotation
        
        // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
        locationManager.stopMonitoringForRegion(regionAnnotation.region!)
        regionView.removeRadiusOverlay()
        regionsMapView.removeAnnotation(regionAnnotation)
    }
    
    
    //MARK: - CLLocationManagerDelegate
    
    // When the user has granted authorization, start the standard location service.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse
            || status == .AuthorizedAlways {
            // Start the standard location service.
            locationManager.startUpdatingLocation()
        }
    }
    
    // A core location error occurred.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("didFailWithError: %@", error)
    }
    
    // The system delivered a new location.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        let oldLocation: CLLocation? = locations.count > 1 ? locations[locations.count - 2] : nil
        NSLog("didUpdateToLocation %@ from %@", newLocation, oldLocation ?? "")
        
        // Work around a bug in MapKit where user location is not initially zoomed to.
        if oldLocation == nil {
            // Zoom to the current user location.
            let userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0)
            regionsMapView.setRegion(userLocation, animated: true)
        }
    }
    
    // The device entered a monitored region.
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let event = String(format: "didEnterRegion %@ at %@", region.identifier, NSDate())
        NSLog("%@ %@", #function, event)
        
        self.updateWithEvent(event)
    }
    
    // The device exited a monitored region.
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let event = String(format: "didExitRegion %@ at %@", region.identifier, NSDate())
        NSLog("%@ %@", #function, event)
        
        self.updateWithEvent(event)
    }
    
    // A monitoring error occurred for a region.
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        let event = String(format: "monitoringDidFailForRegion %@: %@", region!.identifier, error)
        NSLog("%@ %@", #function, event)
        
        self.updateWithEvent(event)
        
    }
    
    
    //MARK: - RegionsViewController
    
    /*
     This method swaps the visible view between the map view and the table of region events.
     The "add region" button in the navigation bar is also altered to only be enabled when the map is shown.
     */
    @IBAction func switchViews() {
        // Swap the hidden status of the map and table view so that the appropriate one is now showing.
        self.regionsMapView.hidden = !self.regionsMapView.hidden
        self.updatesTableView.hidden = !self.updatesTableView.hidden
        
        // Adjust the "add region" button to only be enabled when the map is shown.
        var navigationBarItems = self.navigationBar.items
        let addRegionButton = navigationBarItems![0].rightBarButtonItem
        addRegionButton?.enabled = !addRegionButton!.enabled
        
        // Reload the table data and update the icon badge number when the table view is shown.
        if !updatesTableView.hidden {
            updatesTableView.reloadData()
        }
    }
    
    /*
     This method creates a new region based on the center coordinate of the map view.
     A new annotation is created to represent the region and then the application starts monitoring the new region.
     */
    @IBAction func addRegion() {
        guard CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) else {
            NSLog("Region monitoring is not available.")
            return
        }
        // Create a new region based on the center of the map view.
        let coord = CLLocationCoordinate2DMake(regionsMapView.centerCoordinate.latitude, regionsMapView.centerCoordinate.longitude)
        let newRegion = CLCircularRegion(center: coord,
                                         radius: 1000.0,
                                         identifier: String(format: "%f, %f", regionsMapView.centerCoordinate.latitude, regionsMapView.centerCoordinate.longitude))
        newRegion.notifyOnEntry = true
        newRegion.notifyOnExit = true
        
        // Create an annotation to show where the region is located on the map.
        let myRegionAnnotation = RegionAnnotation(CLCircularRegion: newRegion)
        myRegionAnnotation.coordinate = newRegion.center
        myRegionAnnotation.radius = newRegion.radius
        
        regionsMapView.addAnnotation(myRegionAnnotation)
        
        // Start monitoring the newly created region.
        locationManager.startMonitoringForRegion(newRegion)
        
    }
    
    
    /*
     This method adds the region event to the events array and updates the icon badge number.
     */
    func updateWithEvent(event: String) {
        // Add region event to the updates array.
        updateEvents.insert(event, atIndex: 0)
        
        // Update the icon badge number.
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        
        if !updatesTableView.hidden {
            updatesTableView.reloadData()
        }
    }
    
    
}