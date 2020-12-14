//
//  WriteTransaction.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/10/20.
//

import Foundation
import RealmSwift

public protocol WriteTransaction {
    func add<T: Persistable>(_ value: T, update: Realm.UpdatePolicy)
}

public extension WriteTransaction {
    func add<T: Persistable>(_ value: T, update: Realm.UpdatePolicy = .error) {
        add(value, update: update)
    }
}

public final class DefaultWriteTransaction: WriteTransaction {
    private let realm: Realm
    
    internal init(realm: Realm) {
        self.realm = realm
    }
    
    public func add<T: Persistable>(_ value: T, update: Realm.UpdatePolicy = .error) {
        realm.add(value.managedObject(), update: update)
    }
}
