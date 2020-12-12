//
//  MemoEntity+CoreDataProperties.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//
//

import Foundation
import CoreData


extension MemoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoEntity> {
        return NSFetchRequest<MemoEntity>(entityName: "MemoEntity")
    }

    @NSManaged public var uid: String?
    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var content: String?
    @NSManaged public var imagePath: String?

}

extension MemoEntity : Identifiable {

}
