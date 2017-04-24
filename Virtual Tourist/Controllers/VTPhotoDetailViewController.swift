//
//  VTPhotoDetailViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/24/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class VTPhotoDetailViewController: UIViewController {

    // MARK: - Class Variables
    var photo: UIImage?
    var titleString: String?
    
    // MARK: - IBOutlets
    @IBOutlet weak var flickrPhoto: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure that everything exists before applying the UI
        
        // The photo should always be there
        if let photo = self.photo {
            flickrPhoto.image = photo
        } else {
            print("There was no photo to load")
        }
        
        // This may not exist
        if let titleString = titleString {
            photoTitle.text = titleString
        }
        
    }

}
