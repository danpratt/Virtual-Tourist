//
//  FlickrNetworkSearch.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/20/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrNetworkSearch {
    
    // Gets images from Flickr near a lat/long coordinate
    static func findFlickrImagesAtLocation(latitude: Double, longitude: Double, page: Int? = nil, pin: Pin, completion: @escaping(_ success: Bool, _ noPhotos: Bool) -> Void) {
        
        // Build a URL
        let url = URL(string: Constants.getUrlFromLocation(latitude: latitude, longitude: longitude, page: page))
        
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        
        var noPhotos = false
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it
            func displayError(_ error: String) {
                print(error)
                print("URLRequest at time of error: \(request)")
                completion(false, noPhotos)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request")
                return
            }
            
            // parse the data
            let parsedJSONData: [String:AnyObject]!
            do {
                parsedJSONData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedJSONData[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedJSONData)")
                return
            }
            
            // Pick a random index and create the dictionary for this item
            if photoArray.count == 0 {
                noPhotos = true
                displayError("No photos found.")
                return
            }
            
            if page == nil {
                // grab number of pages to use to generate random number
                guard let numPages: Int = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    displayError("Could not get number of pages")
                    return
                }
                
                // If there are more than 4000 photos near area, the most flickr will return is 4000
                // This means that with 30 per page, the highest page will be 133
                var maxPage = 133
                
                // If there are fewer than 133 pages, then we will need to pick the smaller number
                if numPages < maxPage {
                    maxPage = numPages
                }
                
                // randomly pick a page
                let randomPageNumber = Int(arc4random_uniform(UInt32(maxPage)))

                let _ = findFlickrImagesAtLocation(latitude: latitude, longitude: longitude, page: randomPageNumber, pin: pin, completion: { (success, noPhotos) in
                    completion(success, noPhotos)
                })
            } else // We have found our random page load up the photo data
                {
                    DispatchQueue.main.async {
                        for photo in photoArray {
                            let farm = photo[Constants.FlickrResponseKeys.Farm] as! Int
                            let id = photo[Constants.FlickrResponseKeys.Id] as! String
                            let server = photo[Constants.FlickrResponseKeys.Server] as! String
                            let secret = photo[Constants.FlickrResponseKeys.Secret] as! String
                            let title = photo[Constants.FlickrResponseKeys.Title] as! String
                            
                            let _ = Photo(serverID: server, farm: farm, id: id, secret: secret, title: title, pin: pin, context: (UIApplication.shared.delegate as! AppDelegate).stack.context)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        (UIApplication.shared.delegate as! AppDelegate).stack.save()
                        completion(true, false)
                    }
                    
                    
                    
            }
        }
        task.resume()
    }
}
    
    

