//
//  Date+Extensions.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/10/20.
//

import Foundation


public extension Date {
    /// SwifterSwift: User’s current calendar.
    var calendar: Calendar {
        // Workaround to segfault on corelibs foundation https://bugs.swift.org/browse/SR-10147
        return Calendar(identifier: Calendar.current.identifier)
    }

    var tomorrow: Date {
        return calendar.date(byAdding: .day, value: 1, to: self) ?? Date()
    }
    
    var isInPast: Bool {
        return self < Date()
    }
}
