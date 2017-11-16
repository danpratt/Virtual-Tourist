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
    
    // MARK: - IBOutlets
    @IBOutlet weak var flickrPhoto: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var photoScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure that everything exists before applying the UI
        
        // The photo should always be there
        if let photo = self.photo {
            flickrPhoto.image = photo
            photoScrollView.minimumZoomScale = 0.5
            photoScrollView.maximumZoomScale = 6.0
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
    
    // MARK: - UIScrollView Delegate Functions
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return flickrPhoto
    }
}
