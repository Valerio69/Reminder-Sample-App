//
//  RalmStorage.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import RealmSwift

final class RealmRemindersStorage: RemindersStorage {

    func fetchAllReminders(completion block: @escaping (Result<[Reminder], ReminderStorageError>) -> Void) {
        // Query and update from any thread
        DispatchQueue(label: "fetch-all-reminders-thread").async {
            autoreleasepool {
                do {
                    let container = try RealmContainer()
                    let reminders = container.objects(ReminderObject.self)
                        .sorted(byKeyPath: "date", ascending: true).map { reminderObject in
                            return Reminder(managedObject: reminderObject)
                        }
                    block(.success(Array(reminders)))
                } catch {
                    block(.failure(.fetchAllFailed(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func deleteReminder(reminder: Reminder, completion block: @escaping (Result<Void, ReminderStorageError>) -> Void) {
        DispatchQueue(label: "delete-reminder-thread").async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    guard let obj = realm.objects(ReminderObject.self).first(where: {
                        $0.identifier == reminder.identifier
                    }) else {
                        block(.failure(.deleteFailed(error: "ASd")))
                        return
                    }
                    
                    try realm.write {
                        realm.delete(obj)
                    }
                    block(.success(()))
                } catch {
                    print(error)
                    block(.failure(.deleteFailed(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func deleteAllReminders(completion block: @escaping (Result<Void, ReminderStorageError>) -> Void) {
        DispatchQueue(label: "delete-reminder-thread").async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                
                    let objs = realm.objects(ReminderObject.self)
                    if objs.count > 0 {
                        try realm.write {
                            realm.delete(objs)
                        }
                    }
                    block(.success(()))
                } catch {
                    print(error)
                    block(.failure(.deleteFailed(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func deleteOldReminders(completion block: @escaping (Result<Void, ReminderStorageError>) -> Void) {
        DispatchQueue(label: "delete-reminder-thread").async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    
                    let objs = realm.objects(ReminderObject.self).filter { $0.date != nil && $0.date!.isInPast }
                    if objs.count > 0 {
                        try realm.write {
                            realm.delete(objs)
                        }
                    }
                    block(.success(()))
                } catch {
                    print(error)
                    block(.failure(.deleteFailed(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func addReminder(reminder: Reminder, completion block: @escaping (Result<Void, ReminderStorageError>) -> Void) {
        DispatchQueue(label: "add-reminder-thread").async {
            autoreleasepool {
                do {
                    let container = try RealmContainer()
                    try container.write { transaction in
                        transaction.add(reminder)
                    }
                    block(.success(()))
                } catch {
                    print(error)
                    block(.failure(.deleteFailed(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func updateReminder(reminder: Reminder, completion block: @escaping (Result<Void, ReminderStorageError>) -> Void) {
        DispatchQueue(label: "update-reminder-thread").async {
            autoreleasepool {
                do {
                    let container = try RealmContainer()
                    try container.write { transaction in
                        transaction.add(reminder, update: .modified)
                    }
                    block(.success(()))
                } catch {
                    print(error)
                    block(.failure(.deleteFailed(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func contains(reminder: Reminder) -> Bool {
        autoreleasepool {
            do {
                let container = try RealmContainer()
                return container.objects(ReminderObject.self).contains { $0.identifier == reminder.identifier }
            } catch {
                return false
            }
        }
    }

}
