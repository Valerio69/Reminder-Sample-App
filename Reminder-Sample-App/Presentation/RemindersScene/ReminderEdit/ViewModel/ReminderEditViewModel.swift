//
//  ReminderEditViewModel.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/11/20.
//

import Foundation
import NotificationCenter

struct ReminderEditViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let popViewController: () -> Void
}

protocol ReminderEditViewModelInput {
    func viewDidLoad()
    func didSaveReminder(title: String?, content: String?)
    func didSelectReminderDate(date: Date)
    func didSelectImage(data: Data)
}

protocol ReminderEditViewModelOutput {
    var screenTitle: String { get }
    var reminderTitle: String? { get }
    var reminderContent: String? { get }
    var reminderDate: Observable<Date?> { get }
    var reminderImageData: Observable<Data?> { get }
    var errorTitle: String { get }
    var saveError: Observable<String> { get }
    var saveSuccess: Observable<Bool> { get }
}

protocol ReminderEditViewModel: ReminderEditViewModelInput, ReminderEditViewModelOutput {}

class DefaultRemidnerEditViewModel: ReminderEditViewModel {
    
    private let storage: RemindersStorage
    private let actions: ReminderEditViewModelActions?
    private let identifier: String
    
    var screenTitle: String = "Reminder".localized()
    var reminderTitle: String?
    var reminderContent: String?
    var reminderDate: Observable<Date?> = Observable(Date().tomorrow)
    var reminderImageData: Observable<Data?> = Observable(nil)
    var saveError: Observable<String> = Observable("")
    var saveSuccess: Observable<Bool> = Observable(false)
    var errorTitle: String = "Error".localized()
    
    init(storage: RemindersStorage,
         actions: ReminderEditViewModelActions?,
         reminder: Reminder = Reminder(identifier: UUID().uuidString,
                                       title: nil,
                                       content: nil,
                                       imageData: nil,
                                       date: Date().tomorrow)) {
        self.storage = storage
        self.actions = actions
        self.identifier = reminder.identifier
        self.reminderTitle = reminder.title
        self.reminderContent = reminder.content
        self.reminderDate.value = reminder.date
        if let data = reminder.imageData {
            self.reminderImageData.value = data
        } else {
            self.reminderImageData.value = nil
        }
    }
    
    func viewDidLoad() {
            
    }
    
    func didSaveReminder(title: String?, content: String?) {
        guard let title = title, title.isEmpty == false else {
            saveError.value = "Title can't be empty".localized()
            return
        }
        
        // Save the image into documents diretory and store its path
        let reminder = Reminder(identifier: identifier,
                                title: title,
                                content: content,
                                imageData: reminderImageData.value,
                                date: reminderDate.value)
        
        if storage.contains(reminder: reminder) {
            // Update
            storage.updateReminder(reminder: reminder) { [weak self] (result) in
                switch result {
                case .success():
                    print("success")
                    
                    self?.scheduleNotification(reminder: reminder)
                    
                    self?.actions?.popViewController()
                case .failure(_):
                    self?.saveError.value = "Unable to update the reminder".localized()
                    self?.saveSuccess.value = false
                }
            }
        } else {
            storage.addReminder(reminder: reminder) { [weak self] (result) in
                switch result {
                case .failure(_):
                    self?.saveError.value = "Unable to save the reminder".localized()
                    self?.saveSuccess.value = false
                case .success():
                    print("success")
                    self?.scheduleNotification(reminder: reminder)
                    self?.actions?.popViewController()
                }
            }
        }

    }
    
    func didSelectReminderDate(date: Date) {
        reminderDate.value = date
    }
    
    func didSelectImage(data: Data) {
        reminderImageData.value = data
    }
    
    private func scheduleNotification(reminder: Reminder) {
        guard let date = reminder.date,
              let title = reminder.title else { return }
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                // remove previous notification
                center.removePendingNotificationRequests(withIdentifiers: [reminder.identifier])
                center.removeDeliveredNotifications(withIdentifiers: [reminder.identifier])
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = reminder.content ?? ""
                content.categoryIdentifier = reminder.identifier
                content.userInfo = ["data": "test"]
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            } else {
                
            }
        }
    }
    
}

