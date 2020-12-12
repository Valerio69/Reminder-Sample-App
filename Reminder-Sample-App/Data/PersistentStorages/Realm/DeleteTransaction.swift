//
//  DeleteTransaction.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/10/20.
//

import Foundation
import RealmSwift

public protocol DeleteTransaction {
    func delete<T: Persistable>(_ value: T)
}

public final class DefaultDeleteTransaction: DeleteTransaction {
    private let realm: Realm
    
    internal init(realm: Realm) {
        self.realm = realm
    }
    
    public func delete<T: Persistable>(_ value: T) {
        realm.delete(value.managedObject())
    }
}
