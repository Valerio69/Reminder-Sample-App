//
//  RemindersSearchFlowCoordinatorDependencies.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import UIKit

protocol RemindersFlowCoordinatorDependencies  {
    func makeRemindersListViewController(actions: RemindersListViewModelActions) -> RemindersListViewController
    func makeReminderDetailsViewController(reminder: Reminder, actions: ReminderDetailsViewModelActions?) -> ReminderDetailsViewController
    func makeReminderEditViewController(reminder: Reminder?, actions: ReminderEditViewModelActions?) -> ReminderEditViewController
}


final class RemindersFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: RemindersFlowCoordinatorDependencies
    
    private weak var remindersListVC: RemindersListViewController?
    
    init(navigationController: UINavigationController,
         dependencies: RemindersFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
        
        let actions = RemindersListViewModelActions(showReminderDetails: showReminderDetails,
                                                    editReminder: showReminderEdit)
        let vc = dependencies.makeRemindersListViewController(actions: actions)
        
        navigationController?.pushViewController(vc, animated: false)
        remindersListVC = vc
    }
    
    private func showReminderDetails(reminder: Reminder) {
        let actions = ReminderDetailsViewModelActions(showRemindersEdit: showReminderEdit,
                                                      popViewController: popViewController)
        let vc = dependencies.makeReminderDetailsViewController(reminder: reminder,
                                                                actions: actions)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showReminderEdit(reminder: Reminder?) {
        let actions = ReminderEditViewModelActions(popViewController: popViewController)
        let vc = dependencies.makeReminderEditViewController(reminder: reminder,
                                                             actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func popViewController() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
}

