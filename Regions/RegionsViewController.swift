//
//  RegionsViewController.swift
//  Regions
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/16.
//
//
/*
     File: RegionsViewController.h
     File: RegionsViewController.m
 Abstract: This controller manages the CLLocationManager for location updates and switches the interface between showing the region map and the updates table list. This controller also manages adding and removing regions to be monitored by the application.
  Version: 1.1

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

import UIKit
import MapKit
import CoreLocation

@objc(RegionsViewController)
class RegionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationBarDelegate {
    
    @IBOutlet var regionsMapView: MKMapView!
    @IBOutlet var updatesTableView: UITableView!
    var updateEvents: [String] = []
    var locationManager: CLLocationManager!
    @IBOutlet var navigationBar: UINavigationBar!
    
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
        
        // Create location manager with filters set for battery efficiency.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 8.0, *) {
            if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.startUpdatingLocation()
            }
        } else {
            
            // Start updating location changes.
            locationManager.startUpdatingLocation()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        // Get all regions being monitored for this application.
        let regions = locationManager.monitoredRegions
        
        // Iterate through the regions and add annotations to the map for each of them.
        for region in regions where region is CLCircularRegion {
            let annotation = RegionAnnotation(CLCircularRegion: region as! CLCircularRegion)
            regionsMapView.addAnnotation(annotation)
        }
    }
    
    
    //- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //    // Return YES for supported orientations
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //}
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    
    //MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateEvents.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel!.font = UIFont.systemFontOfSize(12.0)
        cell!.textLabel!.text = updateEvents[indexPath.row]
        cell!.textLabel!.numberOfLines = 4
        
        return cell!
    }
    
    
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
            
            let newRegion = CLCircularRegion(center: regionAnnotation.coordinate, radius: 1000.0, identifier: String(format: "%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude))
            regionAnnotation.region = newRegion
            
            locationManager.startMonitoringForRegion(regionAnnotation.region!)
        }
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let regionView = view as! RegionAnnotationView
        let regionAnnotation = regionView.annotation as! RegionAnnotation
        
        // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
        locationManager.stopMonitoringForRegion(regionAnnotation.region!)
        regionView.removeRadiusOverlay()
        regionsMapView.removeAnnotation(regionAnnotation)
    }
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("didFailWithError: %@", error)
    }
    
    
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
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let event = String(format: "didEnterRegion %@ at %@", region.identifier, NSDate())
        
        self.updateWithEvent(event)
    }
    
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let event = String(format: "didExitRegion %@ at %@", region.identifier, NSDate())
        
        self.updateWithEvent(event)
    }
    
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        let event = String(format: "monitoringDidFailForRegion %@: %@", region!.identifier, error)
        
        self.updateWithEvent(event)
        
    }
    
    //###
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if #available(iOS 8.0, *) {
            if status == .AuthorizedAlways {
                locationManager.startUpdatingLocation()
            } else {
                //TODO: Show info for user
                NSLog("This sample app needs to access location authorization")
            }
        }
    }
    
    
    //MARK: - RegionsViewController
    
    /*
    This method swaps the visibility of the map view and the table of region events.
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
        
        // Create an annotation to show where the region is located on the map.
        let myRegionAnnotation = RegionAnnotation(CLCircularRegion: newRegion)
        myRegionAnnotation.coordinate = newRegion.center
        myRegionAnnotation.radius = newRegion.radius
        
        regionsMapView.addAnnotation(myRegionAnnotation)
        
        // Start monitoring the newly created region.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringForRegion(newRegion)
        
    }
    
    
    /*
    This method adds the region event to the events array and updates the icon badge number.
    */
    func updateWithEvent(event: String) {
        // Add region event to the updates array.
        updateEvents.insert(event, atIndex: 0)
        
        // Update the icon badge number.
        UIApplication.sharedApplication().applicationIconBadgeNumber++
        
        if !updatesTableView.hidden {
            updatesTableView.reloadData()
        }
    }
    
    
}