//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/21/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation

struct Constants {
    
    //MARK: - Arguments
    struct Arguments {
        static let APIKey = "4301450731d39c0270b8bb43da4cf0e4"
        static let SafeSearch = "1" // Current safe search setting is set to safest to prevent non-family friendly results
        static let KMRadius = "15" // Setting for how big a radius of circle around given coordinates to show images from
        static let Format = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
    }
    
    // MARK: - Argument Keys
    struct ArgumentKeys {
        static let Method = "?method="
        static let APIKey = "&api_key="
        static let SafeSearch = "&safe_search="
        static let Latitude = "&lat="
        static let Longitude = "&lon="
        static let KMRadius = "&radius="
        static let Format = "&format="
        static let NoJSONCallback = "&nojsoncallback="
    }
    
    // MARK: - Method URLs
    struct MethodUrls {
        static let FlickrURL = "https://api.flickr.com/services/rest/"
        static let SearchMethod = "flickr.photos.search"
    }
    
    // MARK: - Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    static func getUrlFromLocation(latitude: Double, longitude: Double) -> String {
        
        print(latitude)
        print(longitude)
        
        let url = MethodUrls.FlickrURL + ArgumentKeys.Method + MethodUrls.SearchMethod
        let parameters = ArgumentKeys.APIKey + Arguments.APIKey + ArgumentKeys.SafeSearch + Arguments.SafeSearch + ArgumentKeys.Format + Arguments.Format + ArgumentKeys.NoJSONCallback + Arguments.DisableJSONCallback
        let coordinateParams = ArgumentKeys.Latitude + String(latitude) + ArgumentKeys.Longitude + String(longitude) + ArgumentKeys.KMRadius + Arguments.KMRadius
        
        return url+parameters+coordinateParams
        
    }
    
}
