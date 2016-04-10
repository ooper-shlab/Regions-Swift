//
//  RegionAnnotation.swift
//  Regions
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/16.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The annotation to represent a region that is being monitored.
 */

import UIKit
import MapKit

@objc(RegionAnnotation)
class RegionAnnotation: NSObject, MKAnnotation {
    
    var region: CLRegion?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var radius: CLLocationDistance = 0.0 {
        willSet {willSetRadius(newValue)}
        didSet {didSetRadius(oldValue)}
    }
    var title: String?
    
    // Initialize the annotation object.
    override init() {
        self.title = "Monitored Region"
        super.init()
        
    }
    
    
    // Initialize the annotation object with the monitored region.
    init(CLCircularRegion newRegion: CLCircularRegion) {
        
        self.region = newRegion
        self.coordinate = newRegion.center
        self.radius = newRegion.radius
        self.title = "Monitored Region"
        super.init()
        
    }
    
    
    /*
    This method provides a custom setter so that the model is notified when the subtitle value has changed, which is derived from the radius.
    */
    private func willSetRadius(newRadius: CLLocationDistance) {
        self.willChangeValueForKey("subtitle")
    }
    
    private func didSetRadius(oldValue: CLLocationDistance) {
        self.didChangeValueForKey("subtitle")
    }
    
    
    var subtitle: String? {
        return String(format: "Lat: %.4F, Lon: %.4F, Rad: %.1fm",  coordinate.latitude, coordinate.longitude, radius)
    }
    
    
}