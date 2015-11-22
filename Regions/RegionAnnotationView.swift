//
//  RegionAnnotationView.swift
//  Regions
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/16.
//
//
/*
     File: RegionAnnotationView.h
     File: RegionAnnotationView.m
 Abstract: This is a custom MKAnnotationView that handles updating and removing the radius overlay to show where the region surrounding an annotation is.
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

@objc(RegionAnnotationView)
class RegionAnnotationView: MKPinAnnotationView {
    private var radiusOverlay: MKCircle?
    private var isRadiusUpdated: Bool = false
    
    var map: MKMapView?
    var theAnnotation: RegionAnnotation!
    
    init(annotation: RegionAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: annotation.title!)
        
        self.canShowCallout	= true
        self.multipleTouchEnabled = false
        self.draggable = true
        self.animatesDrop = true
        self.map = nil
        theAnnotation = annotation
        if #available(iOS 9.0, *) {
            self.pinTintColor = UIColor.purpleColor()
        } else {
            self.pinColor = MKPinAnnotationColor.Purple
        }
        radiusOverlay = MKCircle(centerCoordinate: theAnnotation.coordinate, radius: theAnnotation.radius)
        
        map?.addOverlay(radiusOverlay!) //### Never executed here...
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func removeRadiusOverlay() {
        // Find the overlay for this annotation view and remove it if it has the same coordinates.
        for overlay in map?.overlays ?? [] {
            if let circleOverlay = overlay as? MKCircle {
                let coord = circleOverlay.coordinate
                
                if coord.latitude == theAnnotation.coordinate.latitude && coord.longitude == theAnnotation.coordinate.longitude {
                    map?.removeOverlay(overlay)
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
            
            map?.addOverlay(MKCircle(centerCoordinate: theAnnotation.coordinate, radius: theAnnotation.radius))
            
            self.canShowCallout = true
        }
    }
    
    
}