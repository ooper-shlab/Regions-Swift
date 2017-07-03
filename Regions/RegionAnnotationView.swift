//
//  RegionAnnotationView.swift
//  Regions
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/16.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The custom annotation view to display a region that is being monitored.
 */

import UIKit
import MapKit

@objc(RegionAnnotationView)
class RegionAnnotationView: MKPinAnnotationView {
    
    weak var map: MKMapView?
    weak var theAnnotation: RegionAnnotation!
    
    private var radiusOverlay: MKCircle?
    private var isRadiusUpdated: Bool = false
    
    // Initialize the annotation view object. This is the designated initializer.
    init(annotation: RegionAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: annotation.title!)
        
        self.canShowCallout	= true
        self.isMultipleTouchEnabled = false
        self.isDraggable = true
        self.animatesDrop = true
        self.map = nil
        theAnnotation = annotation
        if #available(iOS 9.0, *) {
            self.pinTintColor = UIColor.purple
        } else {
            self.pinColor = MKPinAnnotationColor.purple
        }
        radiusOverlay = MKCircle(center: theAnnotation.coordinate, radius: theAnnotation.radius)
        
        map?.add(radiusOverlay!) //### Never executed here...
        
    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func removeRadiusOverlay() {
        // Find the overlay for this annotation view and remove it if it has the same coordinates.
        for overlay in map?.overlays ?? [] {
            if let circleOverlay = overlay as? MKCircle {
                let coord = circleOverlay.coordinate
                
                if coord.latitude == theAnnotation.coordinate.latitude && coord.longitude == theAnnotation.coordinate.longitude {
                    map?.remove(overlay)
                }
            }
        }
        
        isRadiusUpdated = false
    }
    
    
    func updateRadiusOverlay() {
        if !isRadiusUpdated {
            isRadiusUpdated = true
            
            self.removeRadiusOverlay()
            
            self.canShowCallout = false
            
            map?.add(MKCircle(center: theAnnotation.coordinate, radius: theAnnotation.radius))
            
            self.canShowCallout = true
        }
    }
    
    
}
