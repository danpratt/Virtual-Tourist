//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/24/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var rawImageData: NSData?
    @NSManaged public var imageURLString: String?
    @NSManaged public var title: String?
    @NSManaged public var farm: Int32
    @NSManaged public var id: String?
    @NSManaged public var secret: String?
    @NSManaged public var serverID: String?
    @NSManaged public var location: Pin?

}
