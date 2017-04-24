//
//  VTLocationPhotosViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/20/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "FlickrPhotoCell"

class VTLocationPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    var pin: Pin?
    var photos: [Photo]?
    
    // Delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - IBOutlets
    @IBOutlet weak var flickrPhotosCollectionView: UICollectionView!
    @IBOutlet weak var flickrPhotosFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var locationMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lat = pin?.latitude, let long = pin?.longitude {
            locationMap.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, long), MKCoordinateSpanMake(1, 1)), animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationMap.region.center
            locationMap.addAnnotation(annotation)
            
            // Load the photos
            photos = pin?.album?.allObjects as? [Photo]
            
            // get the flow layout applied
            didRotate(self)
            
            // Check for rotation
            NotificationCenter.default.addObserver(self, selector: #selector(didRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            
        }
        
        self.reloadInputViews()

    }

    // MARK: - Collection View Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCollectionViewCell
        let photoInfo = photos?[indexPath.row]
        
        if cell.flickrImage.image == nil && !cell.activity.isAnimating {
            cell.activity.startAnimating()
        }
        
        // Configure the cell
        if let imageData = photoInfo?.rawImageData {
            cell.activity.stopAnimating()
            cell.flickrImage.image = UIImage(data: imageData as Data)
        } else {
            downloadImage(urlString: (photoInfo?.imageURLString!)!, completionHandler: { (image, data) in
                cell.activity.stopAnimating()
                cell.flickrImage.image = image
                photoInfo?.rawImageData = data
                self.delegate.stack.save()
            })
        }
    
        return cell
    }
    
    // Handle downloading image
    private func downloadImage(urlString: String, completionHandler handler: @escaping (_ image: UIImage, _ data: NSData) -> Void){
        
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            
            if let url = URL(string: urlString), let imgData = try? Data(contentsOf: url), let img = UIImage(data: imgData) {
                
                // all set and done, run the completion closure!
                DispatchQueue.main.async(execute: { () -> Void in
                    handler(img, imgData as NSData)
                })
            }
        }
    }
    
    // MARK: Flow Layout
    
    // Setup the layout depending on orientation
    func setupFlowLayout(_ size: CGSize) {
        // set space used in calculation from flowLayout settings set in Storyboard.  If you want to adjust the space, do it in storyboard, not here
        let space: CGFloat = flickrPhotosFlowLayout.sectionInset.left
        
        // set number of items in a row.  3 for portrait, 5 for landscape
        var photosInRow: CGFloat {
            if size.height > size.width {
                return 3
            } else {
                return 5
            }
        }
        
        // calculate item dimensions based on screen width
        // Create constant for width, to make calculation easier to read
        // Subtract 32 to compensate for auto layout setup
        let width = size.width - 32
        // Remove the spaces between items from the available screen real estate to the items
        let widthAvailableToItems = width - ((photosInRow + 1) * space)
        // Using the available real estate, split it up depending on how many items we want to display based on orientation
        let itemSize = (widthAvailableToItems / photosInRow)
        
        // Now just setup the item as a square with the size we figured out
        // Using squares because they are much more visually appealing
        flickrPhotosFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
    }
    
    // Get new screen size and update flowLayout when the screen rotates
    func didRotate(_: Any) {
        setupFlowLayout(view.frame.size)
    }


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
