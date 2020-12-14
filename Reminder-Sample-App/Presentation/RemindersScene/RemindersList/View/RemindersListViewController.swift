//
//  RemindersListViewController.swift
//  Reminder-Sample-App
//
//  Created by Valerio Sebastianelli on 12/9/20.
//

import UIKit

class RemindersListViewController: UIViewController {
    
    private var viewModel: RemindersListViewModel!
    
    private lazy var remindersTable: UITableView = {
        let t = UITableView()
        t.dataSource = self
        t.delegate = self
        t.register(ReminderListItemCell.self, forCellReuseIdentifier: ReminderListItemCell.reuseIdentifier)
        // Row Height will be calculated using the cell's sizeThatFit() method.
        // The Nest 2 properties must be set for this to work properly.
        //t.estimatedRowHeight = ReminderListItemCell.height
        //t.rowHeight = UITableView.automaticDimension
        // Remove the Separators after the last cell.
        t.tableFooterView = UIView()
        return t
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    static func create(with viewModel: RemindersListViewModel) -> RemindersListViewController {
        let view = RemindersListViewController()
        view.viewModel = viewModel
        return view
    }

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppear()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        remindersTable.pin.top().left(view.pin.safeArea.left).right(view.pin.safeArea.right).bottom(view.pin.safeArea.bottom)
        remindersTable.keyboardDismissMode = .onDrag
    }
    
    private func setup() {
        definesPresentationContext = true
        view.backgroundColor = .white
        title = viewModel.screenTitle
        
        searchController.searchBar.barStyle = .black
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.searchBar.placeholder = "Search".localized()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        view.addSubview(remindersTable)
    }
    
    private func bind() {
        viewModel.items.observe(on: self) { [weak self] _ in self?.refreshList() }
    }
    
    private func refreshList() {
        let createNewReminderButtonBar = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(addReminder))
        
        if !viewModel.isEmpty {
            let deleteRemindersButtonBar = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(deleteReminders))
            navigationItem.rightBarButtonItems = [createNewReminderButtonBar, deleteRemindersButtonBar]
        } else {
            navigationItem.rightBarButtonItems?.removeAll()
            navigationItem.rightBarButtonItem = createNewReminderButtonBar
        }
        
        UIView.transition(with: remindersTable,
                          duration: 0.25,
                          options: .transitionCrossDissolve) {
            self.remindersTable.reloadData()
        }
    }
    
    @objc private func addReminder() {
        viewModel.didTapOnCreateNewReminder()
    }
    
    @objc private func deleteReminders() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAllRemindersAction = UIAlertAction(title: "Delete all Reminders".localized(), style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAllReminders()
        }
        alertController.addAction(deleteAllRemindersAction)
        
        if viewModel.hasExpiredItems {
            let deleteOldRemindersAction = UIAlertAction(title: "Delete expired Reminders".localized(), style: .destructive) { [weak self] _ in
                self?.viewModel.deleteOldReminders()
            }
            alertController.addAction(deleteOldRemindersAction)
        }
        
        

        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension RemindersListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderListItemCell.reuseIdentifier,
                                                       for: indexPath) as? ReminderListItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(ReminderListItemCell.self) with reuseIdentifier: \(ReminderListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }
        cell.viewModel = viewModel.items.value[indexPath.row]
        return cell
    }
    
}

extension RemindersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Do you want to delete this Reminder?".localized(), message: nil, preferredStyle: .actionSheet)
            let deleteReminderAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { [weak self] _ in
                self?.viewModel.deleteItem(at: indexPath.row)
            }
            alertController.addAction(deleteReminderAction)
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


extension RemindersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        remindersTable.pin.all(view.pin.safeArea)
        let searchBar = searchController.searchBar
        guard let query = searchBar.text else {
            return
        }
        viewModel.didSearch(query: query)
    }
}
