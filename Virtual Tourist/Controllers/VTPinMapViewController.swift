//
//  VTPinMapViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/14/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit

// MARK: - VTPinMapViewController Class
class VTPinMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Class Constants
    let minPressDuration = 0.75
    var albumAnnotations = [MKPointAnnotation]()
    
    // MARK: - IBOutlets
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var pinMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup long press recognizer
        longPressRecognizer.minimumPressDuration = minPressDuration
        longPressRecognizer.delaysTouchesBegan = true
        pinMapView.addGestureRecognizer(longPressRecognizer)
        pinMapView.delegate = self
        
    }
    

    // MARK: - IBActions
    
    @IBAction func longPressActionDetected(_ sender: AnyObject) {
        
        if longPressRecognizer.state == .began {
            let position = longPressRecognizer.location(in: pinMapView)
            print("Position is: \(position)")
            
            let coordinate = pinMapView.convert(position, toCoordinateFrom: pinMapView)
            print("Coordinate is: \(coordinate)")
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            albumAnnotations.append(annotation)
            pinMapView.addAnnotation(annotation)
        }
        
        
    }
    
    // MARK: - Delegate Methods
    
    
    // Pin view for displaying all pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "albumLocation"
        var albumAnnotationsView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if albumAnnotationsView == nil {
            albumAnnotationsView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            albumAnnotationsView?.isDraggable = true
            albumAnnotationsView?.animatesDrop = true
            
        } else {
            albumAnnotationsView!.annotation = annotation
        }
        
        return albumAnnotationsView
    }
    
    // Updates the MapView when an annotation is added
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("added")
    }
    
}
