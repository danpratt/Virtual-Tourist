//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/24/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    convenience init(serverID: String, farm: Int, id: String, secret: String, title: String, pin: Pin, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: entity, insertInto: context)
            self.location = pin
            self.title = title
            self.farm = Int32(farm)
            self.serverID = serverID
            self.id = id
            self.secret = secret
            self.imageURLString = "https://farm\(self.farm).staticflickr.com/\(self.serverID!)/\(self.id!)_\(self.secret!).jpg"

            // create a queue and start downloading images in the background
            let downloadQueue = DispatchQueue(label: "download")
            downloadQueue.async { () -> Void in
                // Obtain the Data with the image
                self.rawImageData = try? Data(contentsOf: URL(string: self.imageURLString!)!) as NSData
            }
            
            
        } else {
            fatalError("Unable to find entity in CoreData Model")
        }
    }
}
