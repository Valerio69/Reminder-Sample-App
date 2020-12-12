//
//  ReminderObject.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import RealmSwift

@objcMembers
class ReminderObject: Object {
    dynamic var identifier: String = UUID().uuidString
    dynamic var title: String?
    dynamic var content: String?
    dynamic var imageData: Data?
    dynamic var date: Date?
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
}

extension Reminder: Persistable {
    public init(managedObject: ReminderObject) {
        identifier = managedObject.identifier
        title = managedObject.title
        content = managedObject.content
        imageData = managedObject.imageData
        date = managedObject.date
    }
    
    public func managedObject() -> ReminderObject {
        let reminder = ReminderObject()
        reminder.identifier = identifier
        reminder.title = title
        reminder.content = content
        reminder.imageData = imageData
        reminder.date = date
        return reminder
    }
}
