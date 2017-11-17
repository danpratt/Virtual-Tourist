//
//  VTPhotoDetailViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/24/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class VTPhotoDetailViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Class Variables
    var photo: UIImage?
    var titleString: String?
    // for swiping
    var allPhotos: [Photo]?
    var photoIndex: Int?
    let transition = CATransition()
    
    // MARK: - IBOutlets
    @IBOutlet weak var flickrPhoto: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var photoScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure that everything exists before applying the UI
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeLeft.direction = .left
        swipeRight.direction = .right
    
        // setup gestures for recognizing swipes
        flickrPhoto.addGestureRecognizer(swipeLeft)
        flickrPhoto.addGestureRecognizer(swipeRight)
        
        // setup swipe animation
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionPush
        
        // The photo should always be there
        if let photo = self.photo {
            flickrPhoto.image = photo
            photoScrollView.minimumZoomScale = 1
            photoScrollView.maximumZoomScale = 4.0
            photoScrollView.contentSize = self.flickrPhoto.frame.size
            photoScrollView.delegate = self
        } else {
            print("There was no photo to load")
        }
        
        // This may not exist
        if let titleString = titleString {
            photoTitle.text = titleString
        }
    }
    
    // MARK: - Swipe Gesture Handlers
    
    @objc private func didSwipeLeft() {
        guard let currentIndex = photoIndex, let photosCount = allPhotos?.count else {
            print("Error getting indexes")
            return
        }
        if currentIndex < photosCount - 1 {
            photoIndex = photoIndex! + 1
        } else {
            photoIndex = 0
        }
        transition.subtype = kCATransitionFromRight
        updateCurrentPhoto()
    }
    
    @objc private func didSwipeRight() {
        guard let currentIndex = photoIndex, let photosCount = allPhotos?.count else {
            print("Error getting indexes")
            return
        }
        if currentIndex > 0 {
            photoIndex = photoIndex! - 1
        } else {
            photoIndex = photosCount - 1
        }
        transition.subtype = kCATransitionFromLeft
        updateCurrentPhoto()
    }
    
    private func updateCurrentPhoto() {
        let currentPhoto = allPhotos![photoIndex!]
        guard let imageData = currentPhoto.rawImageData, let image = UIImage(data: imageData as Data) else {
            print("Image is nil")
            return()
        }
        
        // if we get here, we are good to add the transitions
        flickrPhoto.layer.add(transition, forKey: nil)
        photoTitle.layer.add(transition, forKey: nil)
        
        // update photo and text
        flickrPhoto.image = image
        photoTitle.text = currentPhoto.title
        
    }
    
    // MARK: - UIScrollView Delegate Functions
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return flickrPhoto
    }
}
