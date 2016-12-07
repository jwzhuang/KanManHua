//
//  ManHua+CoreDataProperties.swift
//  
//
//  Created by JingWen on 2016/11/24.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ManHua {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManHua> {
        return NSFetchRequest<ManHua>(entityName: "ManHua");
    }

    @NSManaged public var image: String?
    @NSManaged public var last: String?
    @NSManaged public var prepare: Bool
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var chapter: Int16
    @NSManaged public var update: Bool

}
