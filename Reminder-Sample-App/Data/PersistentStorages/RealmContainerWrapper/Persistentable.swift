//
//  Persistentable.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/10/20.
//

import Foundation
import RealmSwift

public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}
