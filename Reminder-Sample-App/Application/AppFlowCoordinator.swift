//
//  AppFlowCoordinator.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import UIKit


final class AppFlowCoordinator {
    
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let remindersSceneDIContainer = appDIContainer.makeRemindersSceneDIContainer()
        let flow = remindersSceneDIContainer.makeRemindersFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}
