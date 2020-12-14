//
//  Reminder.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation

struct Reminder {
    var identifier: String = UUID().uuidString
    var title: String?
    var content: String?
    var imageData: Data?
    var date: Date?
}

extension Reminder: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
