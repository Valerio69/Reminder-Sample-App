//
//  ReminderDetailsViewModel.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import NotificationCenter

struct ReminderDetailsViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showRemindersEdit: (Reminder) -> Void
    let popViewController: () -> Void
}

protocol ReminderDetailsViewModelInput {
    func didSelectEdit()
    func didSelectDelete()
    func viewWillAppear()
}

protocol ReminderDetailsViewModelOutput {
    var reminder: Observable<Reminder> { get }
}

protocol ReminderDetailsViewModel: ReminderDetailsViewModelInput, ReminderDetailsViewModelOutput {}

final class DefaultReminderDetailsViewModel: ReminderDetailsViewModel {
    private let storage: RemindersRepository
    private let actions: ReminderDetailsViewModelActions?
    
    var reminder: Observable<Reminder>
//    var title: String? { return reminder.value.title }
//    var content: String? { return reminder.content }
//    var dateString: String? {
//        guard let date = reminder.date else { return nil }
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .medium
//        return formatter.string(from: date)
//    }
//    var imageData: Data? { return reminder.imageData }
    
    init(reminder: Reminder, storage: RemindersRepository, actions: ReminderDetailsViewModelActions?) {
        self.reminder = Observable(reminder)
        self.storage = storage
        self.actions = actions
    }

}

// Input
extension DefaultReminderDetailsViewModel {
    func viewWillAppear() {
        // refresh the reminder
        storage.fetchAllReminders { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .success(let reminders):
                guard let reminder = reminders.first(where: { $0.identifier == strongSelf.reminder.value.identifier}) else {
                    return
                }
                strongSelf.reminder.value = reminder
            case .failure(_):
                print("Failed to load reminders")
            }
        }
    }
    
    func didSelectEdit() {
        actions?.showRemindersEdit(reminder.value)
    }
    
    func didSelectDelete() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.value.identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [reminder.value.identifier]) 
        storage.deleteReminder(reminder: reminder.value) { [weak self] in
            switch $0 {
            case .success():
                self?.actions?.popViewController()
            case .failure(_):
                print("Unable to delete reminder")
            }
        }
    }
}
