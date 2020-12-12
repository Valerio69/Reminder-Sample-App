//
//  AppDIContainer.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - DIContainers of scenes
    func makeRemindersSceneDIContainer() -> RemindersSceneDIContainer {
        return RemindersSceneDIContainer()
    }
}
