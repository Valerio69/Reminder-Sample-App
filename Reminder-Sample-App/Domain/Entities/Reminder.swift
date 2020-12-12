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
