//
//  FlickrNetworkSearch.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/20/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation


class FlickrNetworkSearch {
    
    
    // Gets images from Flickr near a lat/long coordinate
    static func findFlickrImagesAtLocation(latitude: Double, longitude: Double) {
        
        // Build a URL
        let url = URL(string: Constants.getUrlFromLocation(latitude: latitude, longitude: longitude))
        
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it
            func displayError(_ error: String) {
                print(error)
                print("URLRequest at time of error: \(request)")
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
            
            print("Printing data")
            
            for entry in parsedJSONData {
                print(entry)
            }
            
//            /* GUARD: Are the "photos" and "photo" keys in our result? */
//            guard let photosDictionary = parsedJSONData[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
//                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedJSONData)")
//                return
//            }
            
//            // Pick a random index and create the dictionary for this item
//            if photoArray.count == 0 {
//                displayError("No photos found.")
//                return
//            }
//            
//            // grab number of pages to use to generate random number
//            guard let numPages: Int = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
//                displayError("Could not get number of pages")
//                return
//            }

            
            
            
            
//            let randomPageNumber = Int(arc4random_uniform(UInt32(numPages)))
//            print(randomPageNumber)
            
        }
        
        task.resume()

    }
}
    
    

