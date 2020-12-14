//
//  RemindersStorage.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import RealmSwift

// Repository returns data from a Remote Data (Network),
// Persistent DB Storage Sourceor In-memory Data (Remote or Cached).

enum RemindersRepositoryError: Error {
    case fetchAllFailed(error: String)
    case deleteFailed(error: String)
    case deleteOldRemidnersFailed(error: String)
    case deleteAllRemidnersFailed(error: String)
    case addFailed(error: String)
    case updateFailed(error: String)
}

protocol RemindersRepository {
    func fetchAllReminders(completion block: @escaping (Result<[Reminder], RemindersRepositoryError>) -> Void)
    func deleteReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void)
    func addReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void)
    func updateReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void)
    func contains(reminder: Reminder) -> Bool
    func deleteAllReminders(completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void)
    func deleteOldReminders(completion block: @escaping (Result<[Reminder], RemindersRepositoryError>) -> Void)
}

extension RemindersRepository {
    func fetchAllReminders(completion block: @escaping (Result<[Reminder], RemindersRepositoryError>) -> Void) {}
    func deleteReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {}
    func addReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {}
    func updateReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {}
    func contains(reminder: Reminder) -> Bool { return false }
    func deleteAllReminders(completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {}
    func deleteOldReminders(completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {}
}
