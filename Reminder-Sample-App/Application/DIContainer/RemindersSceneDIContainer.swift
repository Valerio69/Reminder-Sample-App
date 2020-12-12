
import UIKit



final class RemindersSceneDIContainer {
    
    // MARK: - Persistent Storage
    lazy var remindersStorage: RemindersStorage = RealmRemindersStorage()
    
    init() { }
    
    // MARK: - Reminders List
    
    func makeRemindersListViewController(actions: RemindersListViewModelActions) -> RemindersListViewController {
        return RemindersListViewController.create(with: makeRemindersListViewModel(actions:
                                                                                    actions))
    }
    
    func makeRemindersListViewModel(actions: RemindersListViewModelActions) -> RemindersListViewModel {
        return DefaultRemindersListViewModel(storage: remindersStorage,
                                             actions: actions)
    }
    
    // MARK: - Reminder Details
    func makeReminderDetailsViewController(reminder: Reminder,
                                           actions: ReminderDetailsViewModelActions?) -> ReminderDetailsViewController {
        return ReminderDetailsViewController.create(with: makeReminderDetailsViewModel(reminder: reminder,
                                                                                       storage: remindersStorage,
                                                                                       actions: actions))
    }
    
    func makeReminderDetailsViewModel(reminder: Reminder,
                                      storage: RemindersStorage,
                                      actions: ReminderDetailsViewModelActions?) -> ReminderDetailsViewModel {
        return DefaultReminderDetailsViewModel(reminder: reminder,
                                               storage: storage,
                                               actions: actions)
    }
    
    // MARK: - Reminder Edit/Create
    func makeReminderEditViewController(reminder: Reminder?,
                                        actions: ReminderEditViewModelActions?) -> ReminderEditViewController {
        return ReminderEditViewController.create(with: makeReminderEditViewModel(reminder: reminder,
                                                                                 storage: remindersStorage,
                                                                                 actions: actions))
    }
    
    func makeReminderEditViewModel(reminder: Reminder?,
                                   storage: RemindersStorage,
                                   actions: ReminderEditViewModelActions?) -> ReminderEditViewModel {
        return reminder == nil ?
            DefaultRemidnerEditViewModel(storage: storage, actions: actions) :
            DefaultRemidnerEditViewModel(storage: storage, actions: actions, reminder: reminder!)
    }
    
    // MARK: - Flow Coordinators
    func makeRemindersFlowCoordinator(navigationController: UINavigationController) -> RemindersFlowCoordinator {
        return RemindersFlowCoordinator(navigationController: navigationController,
                                           dependencies: self)
    }

}




extension RemindersSceneDIContainer: RemindersFlowCoordinatorDependencies {

}
