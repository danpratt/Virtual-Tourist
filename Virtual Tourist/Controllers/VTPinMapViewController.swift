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
    let minPressDuration = 0.6
    var albumAnnotations = [MKPointAnnotation]()
    var pinData: [Pin] = []
    var savedStateData: [SaveState] = []
    
    // Booleans
    var firstLoad = true
    var dragging = false
    var editButtonEnabled = false
    
    // Delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // Entity Names
    private let SaveStateKey = "SaveState"
    private let PinKey = "Pin"
    private let PhotoKey = "Photo"
    
    // Variables used to update pin location
    var pinIndexToUpdate: Int = -1
    
    // MARK: - IBOutlets
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var pinMapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tapToDeleteFlag: UILabel!  // gets displayed when in edit mode to warn user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup map
        pinMapView.showsBuildings = true
        pinMapView.showsPointsOfInterest = true

        // Setup long press recognizer
        setupLongPress()
        
        // Setup Starting Map View
        setupMapRegion()
        
        // Setup Existing Pins
        setupPinData()
    }
    

    // MARK: - IBActions
    
    // called when edit button is pressed
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButtonEnabled {
            editButtonEnabled = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            tapToDeleteFlag.isHidden = true
        } else {
            editButtonEnabled = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonPressed))
            tapToDeleteFlag.isHidden = false
        }
        
    }
    
    @IBAction func longPressActionDetected(_ sender: AnyObject) {
        
        if longPressRecognizer.state == .began {
            let position = longPressRecognizer.location(in: pinMapView)
            let coordinate = pinMapView.convert(position, toCoordinateFrom: pinMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            albumAnnotations.append(annotation)
            pinMapView.addAnnotation(annotation)
            
            // Store and save to CoreData
            pinData.append(Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: delegate.stack.context))
            
            FlickrNetworkSearch.findFlickrImagesAtLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, pin: pinData[findPinIndexat(latitude: coordinate.latitude, longitude: coordinate.longitude)], completion: { (success) in })
            
            delegate.stack.save()
        }
    }
    
    // MARK: - Private Helper Methods
    func findPinIndexat(latitude: Double, longitude: Double) -> Int {
        for (index, pin) in pinData.enumerated() {
            if latitude == pin.latitude && longitude == pin.longitude {
                return index
            }
        }
        return -1
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
        savedStateData = fetchedSaveStateController.fetchedObjects as! [SaveState]
        if savedStateData.count > 0 {
            let savedStateCoords = savedStateData.popLast()!
            let coord = CLLocationCoordinate2DMake((savedStateCoords.latitude), (savedStateCoords.longitude))
            let span = MKCoordinateSpanMake((savedStateCoords.zoomLatitude), (savedStateCoords.zoomLongitude))
            let region = MKCoordinateRegionMake(coord, span)
            pinMapView.setRegion(region, animated: true)
        }
    }
    
    // Sets up the existing pins
    private func setupPinData() {
        // Fetch existing results
        let fetchedPinController = getFetchControllerFor(entityNamed: PinKey, inContext: delegate.stack.context)
        try? fetchedPinController.performFetch()
        pinData = fetchedPinController.fetchedObjects as! [Pin]
        
        // Load results into the annotations array
        if pinData.count > 0 {
            for pin in pinData {
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                albumAnnotations.append(annotation)
                pinMapView.addAnnotation(annotation)
            }
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
    
    // When the user moves the map around, save the new region so we can load it the next time the application launches
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
            if savedStateData.count > 0 {
                for save in savedStateData {
                    delegate.stack.context.delete(save)
                }
            }
            
            // Save the map position
            savedStateData.append(SaveState(latitude: lat, longitude: lon, zoomLatitude: zLat, zoomLongitude: zLon, context: delegate.stack.context))
            delegate.stack.save()
        }
        
    }
    
    // When an annoation is being dragged, find the Pin data that coorisponds to the annotation
    // After the annotation's coordinates have been changes, change the lat/long of the Pin data as well
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {

        if newState.hashValue != 0 {
            for (index, pin) in pinData.enumerated() {
                if view.annotation?.coordinate.latitude == pin.latitude && view.annotation?.coordinate.longitude == pin.longitude && oldState.hashValue == 0 {
                    pinIndexToUpdate = index  // set the index that we will be updating
                }
            }
        } else {
            dragging = true
            if pinIndexToUpdate != -1 {
                guard let coordinate = view.annotation?.coordinate else {
                    print("Error getting new coordinate")
                    return
                }
                
                // update the coordinate in our pin CoreData object
                pinData[pinIndexToUpdate].latitude = coordinate.latitude
                pinData[pinIndexToUpdate].longitude = coordinate.longitude
                
                // Delete the old photos and load up new ones at the new coordinates
                pinData[pinIndexToUpdate].album = nil
                FlickrNetworkSearch.findFlickrImagesAtLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, pin: pinData[pinIndexToUpdate], completion: { (success) in })
                
                // Set pinIndexToUpdate back to -1 so we don't have any accidents later on
                pinIndexToUpdate = -1
                // save to CoreData
                delegate.stack.save()
            }
        }
    }
    
    // MARK: - Segue Functions
    
    // Map Delegate Method to call segue when user taps on pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Check with the longPressRecognizer to make sure that touches are over
        if longPressRecognizer.state.hashValue == 0 {
            mapView.deselectAnnotation(view.annotation, animated: true)
            // We don't want to load the view if we were just dragging
            if dragging {
                dragging = false
                return
            }
            
            // Going to need the coordinate no matter what now, so get that first
            guard let coordinate = view.annotation?.coordinate else {
                print("Unable to get coordinate for segue")
                return
            }
            
            // check to see if we were editing, if so we will be in delete mode
            // otherwise we will load the album view
            if editButtonEnabled {
                // first remove the annotation from the view
                mapView.removeAnnotation(view.annotation!)
                // get the index we are going to delete
                let pinIndexToDelete = findPinIndexat(latitude: coordinate.latitude, longitude: coordinate.longitude)
                // remove the object from CoreData
                delegate.stack.context.delete(pinData[pinIndexToDelete])
                delegate.stack.save()
            } else {
                performSegue(withIdentifier: "AlbumSegue", sender: coordinate)
            }
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AlbumSegue" {
            
            let coordinate = sender as! CLLocationCoordinate2D
            let flickrAlbumView = segue.destination as! VTLocationPhotosViewController
            for (index, pin) in pinData.enumerated() {
                if pin.latitude == coordinate.latitude && pin.longitude == coordinate.longitude {
                    flickrAlbumView.pin = pinData[index]
                    break
                }
            }
            
        }
    }
    
}
