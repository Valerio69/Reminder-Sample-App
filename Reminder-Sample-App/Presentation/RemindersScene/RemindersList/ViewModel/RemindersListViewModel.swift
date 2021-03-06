//
//  RemindersListViewModel.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation
import NotificationCenter

struct RemindersListViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showReminderDetails: (Reminder) -> Void
    let editReminder: (Reminder?) -> Void
}

protocol RemindersListViewModelInput {
    func viewDidLoad()
    func viewWillAppear()
    func didSearch(query: String)
    func didSelectItem(at index: Int)
    func didTapOnCreateNewReminder()
    func deleteItem(at index: Int)
    func deleteAllReminders()
    func deleteOldReminders()
}

protocol RemindersListViewModelOutput {
    var items: Observable<[RemindersListItemViewModel]> { get }
    var hasExpiredItems: Bool { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
}

protocol RemindersListViewModel: RemindersListViewModelInput, RemindersListViewModelOutput {}

final class DefaultRemindersListViewModel: RemindersListViewModel {
    
    private let storage: RemindersRepository
    private let actions: RemindersListViewModelActions?
    
    var items: Observable<[RemindersListItemViewModel]> = Observable([])
    var emptyDataTitle: String = "Reminders list".localized()
    var errorTitle: String = "Error".localized()
    var searchBarPlaceholder: String = "Search reminders".localized()
    var isEmpty: Bool { return items.value.isEmpty }
    var screenTitle: String = "Reminders".localized()
    
    var hasExpiredItems: Bool {
        hasExpiredItemsCount > 0
    }
    var hasExpiredItemsCount: Int {
        items.value.filter { $0.reminder.date != nil && $0.reminder.date!.isInPast }.count
    }
    
    
    // MARK: - Init
    
    init(storage: RemindersRepository,
         actions: RemindersListViewModelActions? = nil) {
        self.storage = storage
        self.actions = actions
        
        // Not so clean, but this will do for now.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reminderNotificationReceived),
                                               name: NSNotification.Name(rawValue: Constants.ReminderNotificationReceived),
                                               object: nil)
    }

    private func refreshReminders() {
        storage.fetchAllReminders { [weak self] result in
            switch result {
            case .success(let reminders):
                let remindersViewModels = reminders.map(RemindersListItemViewModel.init)
                self?.items.value = remindersViewModels
            case .failure(_):
                break
            }
        }
    }
    
    @objc private func reminderNotificationReceived() {
        print("Notification received")
        refreshReminders()
    }
    
}

// MARK: - INPUT. View event methods

extension DefaultRemindersListViewModel {
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        refreshReminders()
    }
    
    func didSelectItem(at index: Int) {
        guard index < items.value.count else { return }
        actions?.showReminderDetails(items.value[index].reminder)
    }
    
    func didTapOnCreateNewReminder() {
        actions?.editReminder(nil)
    }
    
    func deleteItem(at index: Int) {
        guard index < items.value.count else { return }
        storage.deleteReminder(reminder: items.value[index].reminder) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success():
                let id = strongSelf.items.value[index].reminder.identifier
                print("Deleting notification with id \(id)")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                self?.items.value.remove(at: index)
            case .failure(_):
                print("Error")
            }
        }
    }
    
    func deleteAllReminders() {
        storage.deleteAllReminders { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .success():
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                strongSelf.items.value = []
            case .failure(_):
                print("Failed to delte all reminders")
            }
        }
    }
    
    func deleteOldReminders() {
        storage.deleteOldReminders { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .success(let newReminders):
                let oldSetId = Set(strongSelf.items.value.map { $0.reminder.identifier })
                let newSetId = Set(newReminders.map { $0.identifier })
                let expiredId = Array(oldSetId.symmetricDifference(newSetId))
                // not needed because they should already be expired.
                // but just to be sure...
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: expiredId)
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: expiredId)
                
                let remindersViewModels = newReminders.map(RemindersListItemViewModel.init)
                self?.items.value = remindersViewModels
            case .failure(_):
                print("Failed to delte all reminders")
            }
        }
    }
    
    func didSearch(query: String) {
        if query.isEmpty {
            refreshReminders()
        } else {
            items.value =  items.value.filter {
                if let title = $0.title, title.contains(query) {
                    return true
                }
                if let content = $0.content, content.contains(query) {
                    return true
                }
                return false
            }
        }
    }
    
}
