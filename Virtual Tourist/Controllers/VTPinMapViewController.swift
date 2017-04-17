//
//  VTPinMapViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/14/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - VTPinMapViewController Class
class VTPinMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Class Constants
    let minPressDuration = 0.75
    var albumAnnotations = [MKPointAnnotation]()
    var savedStateInfo: [SaveState] = []
    var firstLoad = true
    
    // Delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // Entity Names
    private let SaveStateKey = "SaveState"
    
    // MARK: - IBOutlets
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var pinMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup long press recognizer
        setupLongPress()
        setupMapRegion()
    }
    

    // MARK: - IBActions
    
    @IBAction func longPressActionDetected(_ sender: AnyObject) {
        
        if longPressRecognizer.state == .began {
            let position = longPressRecognizer.location(in: pinMapView)
            let coordinate = pinMapView.convert(position, toCoordinateFrom: pinMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            albumAnnotations.append(annotation)
            pinMapView.addAnnotation(annotation)
        }
        
        
    }
    
    // MARK: - Private Setup Methods
    
    // Sets up the long press gesture, and adds it to the map view
    private func setupLongPress() {
        longPressRecognizer.minimumPressDuration = minPressDuration
        longPressRecognizer.delaysTouchesBegan = true
        pinMapView.addGestureRecognizer(longPressRecognizer)
        pinMapView.delegate = self
    }
    
    // Sets the map up from where the user left off
    private func setupMapRegion() {
        let fetchedSaveStateController = getFetchControllerFor(entityNamed: SaveStateKey, inContext: delegate.stack.context)
        try? fetchedSaveStateController.performFetch()
        savedStateInfo = fetchedSaveStateController.fetchedObjects as! [SaveState]
        if savedStateInfo.count > 0 {
            let savedStateCoords = savedStateInfo.popLast()!
            let coord = CLLocationCoordinate2DMake((savedStateCoords.latitude), (savedStateCoords.longitude))
            let span = MKCoordinateSpanMake((savedStateCoords.zoomLatitude), (savedStateCoords.zoomLongitude))
            let region = MKCoordinateRegionMake(coord, span)
            pinMapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Private Fetch Methods
    
    private func getFetchControllerFor(entityNamed entityName: String, inContext context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if firstLoad {
            firstLoad = false
        } else {
            // Setup the save info
            let region = mapView.region
            let coords = region.center
            let zoom = region.span
            let lat = coords.latitude
            let lon = coords.longitude
            let zLat = zoom.latitudeDelta
            let zLon = zoom.longitudeDelta
            
            // Make sure we aren't storing more data than we need
            if savedStateInfo.count > 0 {
                for save in savedStateInfo {
                    delegate.stack.context.delete(save)
                }
            }
            
            // Save the map position
            savedStateInfo.append(SaveState(latitude: lat, longitude: lon, zoomLatitude: zLat, zoomLongitude: zLon, context: delegate.stack.context))
            delegate.stack.save()
        }
        
    }
    
    // TODO: - Delete before release
    // Verify annotations coordinates update
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        for annotation in albumAnnotations {
            print(annotation.coordinate)
        }
    }
    
}
