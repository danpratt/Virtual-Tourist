//
//  VTLocationPhotosViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/20/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "FlickrPhotoCell"

class VTLocationPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    var pin: Pin?
    
    // MARK: - IBOutlets
    @IBOutlet weak var flickrPhotosCollectionView: UICollectionView!
    @IBOutlet weak var flickrPhotosFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var locationMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lat = pin?.latitude, let long = pin?.longitude {
            locationMap.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, long), MKCoordinateSpanMake(1, 1)), animated: true)
            
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    // MARK: Flow Layout
    
    // Setup the layout depending on orientation
    func setupFlowLayout(_ size: CGSize) {
        // set space used in calculation from flowLayout settings set in Storyboard.  If you want to adjust the space, do it in storyboard, not here
        let space: CGFloat = flickrPhotosFlowLayout.sectionInset.left
        
        // set number of items in a row.  3 for portrait, 5 for landscape
        var memesInRow: CGFloat {
            if size.height > size.width {
                return 3
            } else {
                return 5
            }
        }
        
        // calculate item dimensions based on screen width
        // Create constant for width, to make calculation easier to read
        let width = size.width
        // Remove the spaces between items from the available screen real estate to the items
        let widthAvailableToItems = width - ((memesInRow + 1) * space)
        // Using the available real estate, split it up depending on how many items we want to display based on orientation
        let itemSize = widthAvailableToItems / memesInRow
        
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
