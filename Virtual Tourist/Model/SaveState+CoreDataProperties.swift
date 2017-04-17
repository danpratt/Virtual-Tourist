//
//  SaveState+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/17/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import CoreData


extension SaveState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SaveState> {
        return NSFetchRequest<SaveState>(entityName: "SaveState")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var zoomLatitude: Double
    @NSManaged public var zoomLongitude: Double

}
