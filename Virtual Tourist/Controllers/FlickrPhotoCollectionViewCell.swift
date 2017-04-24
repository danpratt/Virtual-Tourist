//
//  FlickrPhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/24/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class FlickrPhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    var hasImageLoaded = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var flickrImage: UIImageView!
}
