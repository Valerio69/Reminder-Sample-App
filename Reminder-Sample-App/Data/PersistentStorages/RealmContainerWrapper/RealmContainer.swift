//
//  RealmContainer.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import RealmSwift

// Implement the Container
public final class RealmContainer {
    private let realm: Realm
    
    public convenience init() throws {
        try self.init(realm: Realm())
    }
    
    internal init(realm: Realm) {
        self.realm = realm
    }
    
    public func write(_ block: (DefaultWriteTransaction) throws -> Void) throws {
        let transaction = DefaultWriteTransaction(realm: realm)
        try realm.write {
            try block(transaction)
        }
    }
    
    public func objects<Element: Object>(_ type: Element.Type) -> Results<Element> {
        return realm.objects(type)
    }
    
    public func delete(_ block: (DefaultDeleteTransaction) throws -> Void) throws {
        let transaction = DefaultDeleteTransaction(realm: realm)
        try realm.write {
            try block(transaction)
        }
    }
}
