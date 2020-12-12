//
//  RemindersListItemViewModel.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation

struct RemindersListItemViewModel: Equatable {
    let reminder: Reminder
    
    var title: String? { reminder.title }
    var content: String? { reminder.content }
    var date: String { reminder.date != nil ? dateFormatter.string(from: reminder.date!) : ""}
    var imageData: Data? { reminder.imageData }
    
    static func == (lhs: RemindersListItemViewModel, rhs: RemindersListItemViewModel) -> Bool {
        return lhs.reminder.identifier == rhs.reminder.identifier
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
