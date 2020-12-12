//
//  RemindersStorage.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import RealmSwift

enum ReminderStorageError: Error {
    case fetchAllFailed(error: String)
    case deleteFailed(error: String)
    case addFailed(error: String)
    case updateFailed(error: String)
}

protocol RemindersStorage {
    func fetchAllReminders(completion block: @escaping (Result<[Reminder], ReminderStorageError>) -> Void)
    func deleteReminder(reminder: Reminder, completion block: @escaping (Result<Void, ReminderStorageError>) -> Void)
    func addReminder(reminder: Reminder, completion block: @escaping (Result<Void, ReminderStorageError>) -> Void)
    func updateReminder(reminder: Reminder, completion block: @escaping (Result<Void, ReminderStorageError>) -> Void)
    func contains(reminder: Reminder) -> Bool
    func deleteAllReminders(completion block: @escaping (Result<Void, ReminderStorageError>) -> Void)
    func deleteOldReminders(completion block: @escaping (Result<Void, ReminderStorageError>) -> Void)
}
