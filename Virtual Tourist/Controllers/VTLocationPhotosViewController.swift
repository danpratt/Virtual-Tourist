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
    
    // Booleans
    var deleteModeOn = false
    
    // Delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - IBOutlets
    @IBOutlet weak var flickrPhotosCollectionView: UICollectionView!
    @IBOutlet weak var flickrPhotosFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var locationMap: MKMapView!
    @IBOutlet weak var deletePhotosButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var reloadActivity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lat = pin?.latitude, let long = pin?.longitude {
            locationMap.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, long), MKCoordinateSpanMake(1, 1)), animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationMap.region.center
            locationMap.addAnnotation(annotation)
            
            // Load the photos
            photos = pin?.album?.allObjects as? [Photo]
            
            // If the user has tapped on the pin too soon, Flickr may not have sent results back yet
            // Check to see if there is anything, or if there is the expected 30 items
            if (photos?.count == nil) || (photos?.count)! < 30 {
                
                // If we don't see info from flickr yet, start activity indicator, and disable the delete button
                reloadActivity.startAnimating()
                self.deletePhotosButton.isEnabled = false
                
                // Wait five seconds, then check again
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    self.reloadActivity.stopAnimating()
                    self.photos?.removeAll()
                    self.photos = self.pin?.album?.allObjects as? [Photo]
                    // If we still don't see anything, then we need to let the user know
                    if self.photos?.count == 0 {
                        self.reloadButton.isEnabled = false
                        self.reloadButton.isHidden = false
                        self.reloadButton.setTitle("No Photos Found", for: UIControlState.disabled)
                    } else {
                        // If we found something, re-enable the delete button and reload the data
                        self.deletePhotosButton.isEnabled = true
                        self.flickrPhotosCollectionView.reloadData()
                    }
                })
                
                
            }
            
            // get the flow layout applied
            didRotate(self)
            
            // Check for rotation
            NotificationCenter.default.addObserver(self, selector: #selector(didRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            
        }
        
        self.reloadInputViews()

    }
    
    // MARK: - IBActions
    
    // Called when nav button gets tapped
    // Makes UI changes and sets boolean flag
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if deleteModeOn {
            deletePhotosButton.title = "Delete Photos"
            deletePhotosButton.style = .plain
            deleteModeOn = false
            reloadButton.isHidden = true
            reloadButton.isEnabled = false
        } else {
            deletePhotosButton.title = "Done"
            deletePhotosButton.style = .done
            deleteModeOn = true
            reloadButton.isHidden = false
            reloadButton.isEnabled = true
        }
        
    }

    // Can only be called while in edit mode
    // removes all the old photos and loads new ones
    @IBAction func reloadNewPhotosButtonPressed(_ sender: Any) {
        // Get rid of the reload button and display edit button instead of done again
        deleteButtonPressed(self)
        reloadActivity.startAnimating()
        
        for picture in (pin?.album)! {
            delegate.stack.context.delete(picture as! NSManagedObject)
        }
        
        photos?.removeAll()
        delegate.stack.save()
        
        FlickrNetworkSearch.findFlickrImagesAtLocation(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!, pin: pin!, completion: { (success) in
            if success {
                DispatchQueue.main.async {
                    self.reloadActivity.stopAnimating()
                    self.delegate.stack.save()
                    self.photos = self.pin?.album?.allObjects as? [Photo]
                    self.flickrPhotosCollectionView.reloadData()
                }
            } else {
                let alert = UIAlertController.init(title: "Error loading", message: "There was an error loading images from Flickr.  Please check your network connetion and try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        })
    }

    // MARK: - Collection View Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCollectionViewCell
        let photoInfo = photos?[indexPath.row]
        
        // Check to see if the image is gone (i.e. are we reloading?)
        if photoInfo?.rawImageData == nil {
            cell.flickrImage.image = nil
            cell.activity.startAnimating()
        }
        
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
    
    // MARK: - Functions used for segue
    
    // Called when an item gets tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if deleteModeOn {
            delegate.stack.context.delete((photos?[indexPath.row])!)
            photos?.remove(at: indexPath.row)
            self.delegate.stack.save()
            DispatchQueue.main.async {
                self.flickrPhotosCollectionView.reloadData()
            }
        } else {
            // Make sure that the image has finished loading, otherwise we don't want to try the segue yet
            if !(collectionView.cellForItem(at: indexPath) as! FlickrPhotoCollectionViewCell).activity.isAnimating {
                guard let photo = photos?[indexPath.row] else {
                    print("unable to get photo data for segue")
                    return
                }
                
                performSegue(withIdentifier: "PhotoDetailSegue", sender: photo)
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoDetailSegue" {
            
            let photo = sender as! Photo
            
            let flickrPhotoDetailView = segue.destination as! VTPhotoDetailViewController
            flickrPhotoDetailView.photo = UIImage(data: photo.rawImageData! as Data)
            flickrPhotoDetailView.titleString = photo.title
            
        }
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
}
