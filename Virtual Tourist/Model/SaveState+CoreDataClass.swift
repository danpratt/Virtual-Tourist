//
//  SaveState+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/17/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import CoreData

@objc(SaveState)
public class SaveState: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, zoomLatitude: Double, zoomLongitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "SaveState", in: context) {
            
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.zoomLatitude = zoomLatitude
            self.zoomLongitude = zoomLongitude
            
        } else {
            fatalError("Unable to find entity in CoreData Model")
        }
    }
    
}
