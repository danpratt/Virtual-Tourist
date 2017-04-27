//
//  VTUIAlertDisplay.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/27/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // Present an alert to let user know there was an error
    
    func presentNetworkAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "Error loading", message: "There was an error loading images from Flickr.  Please check your network connetion and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentNoPhotosAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "No Photos Found", message: "There are no photos that exist at this location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
}
