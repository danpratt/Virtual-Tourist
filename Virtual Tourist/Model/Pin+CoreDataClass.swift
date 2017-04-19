//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Daniel Pratt on 4/19/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.album = nil
            
        } else {
            fatalError("Unable to find entity in CoreData Model")
        }
    }

    
}
