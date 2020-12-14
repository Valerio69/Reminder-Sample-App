//
//  RemindersListViewModelTests.swift
//  Reminder-Sample-AppTests
//
//  Created by Valerio Sebastianelli on 12/13/20.
//

import XCTest
@testable import Reminder_Sample_App


class RemindersListViewModelTests: XCTestCase {
    
    class RemindersRepositoryMock: RemindersRepository {

        var expectation: XCTestExpectation?
        var error: RemindersRepositoryError?
        var reminders: [Reminder] = []
        
        
        func fetchAllReminders(completion block: @escaping (Result<[Reminder], RemindersRepositoryError>) -> Void) {
            if let error = error {
                block(.failure(.fetchAllFailed(error: error.localizedDescription)))
            } else {
                block(.success(reminders))
            }
            expectation?.fulfill()
        }
        
        func deleteReminder(reminder: Reminder, completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {
            if let error = error {
                block(.failure(.fetchAllFailed(error: error.localizedDescription)))
            } else {
                if let index = reminders.firstIndex(where: { $0.identifier == reminder.identifier }) {
                    reminders.remove(at: index)
                    block(.success(()))
                } else {
                    block(.failure(.deleteFailed(error: "Reminders does not exist")))
                }
            }
            expectation?.fulfill()
        }
        
        func deleteAllReminders(completion block: @escaping (Result<Void, RemindersRepositoryError>) -> Void) {
            if let error = error {
                block(.failure(.fetchAllFailed(error: error.localizedDescription)))
            } else {
                reminders.removeAll()
                block(.success(()))
            }
            expectation?.fulfill()
        }
        
        func deleteOldReminders(completion block: @escaping (Result<[Reminder], RemindersRepositoryError>) -> Void) {
            if let error = error {
                block(.failure(.fetchAllFailed(error: error.localizedDescription)))
            }
            else {
                let date = Date()
                if reminders.count > 0, reminders.contains(where: { $0.date != nil && $0.date! < date }) {
                    reminders.removeAll(where: { $0.date != nil && $0.date! < date })
                    block(.success(reminders))
                } else {
                    block(.failure(.deleteOldRemidnersFailed(error: "Nothing to delete")))
                }
            }
            expectation?.fulfill()
        }
        
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_whenRemindersRepositoryContainsReminders_thenViewModelContainsTheSameNumberOfItems() throws {
        // given
        let repo = RemindersRepositoryMock()
        repo.expectation = self.expectation(description: "Contains 3 Reminders")
        repo.reminders = [Reminder(), Reminder(), Reminder()]
        let viewModel = DefaultRemindersListViewModel(storage: repo)
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(viewModel.items.value.count, 3)
    }
    
    func test_whenRemindersRepositoryContainsReminders_thenViewModelContainsItemsReflectsTheRepository() throws {
        // given
        let repo = RemindersRepositoryMock()
        repo.expectation = self.expectation(description: "Should match every Reminder")
        repo.reminders = [
            Reminder(title: "T1", content: "C1", imageData: nil, date: Date()),
            Reminder(title: "T2", content: "C2", imageData: nil, date: Date().advanced(by: 60)),
            Reminder(title: "T3", content: "C3", imageData: nil, date: Date().advanced(by: 120)),
            Reminder(title: "T4", content: "C4", imageData: nil, date: Date().advanced(by: 180)),
        ]
        let viewModel = DefaultRemindersListViewModel(storage: repo)
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(viewModel.items.value.count, 4)
        
        for (index, item) in viewModel.items.value.enumerated() {
            XCTAssertEqual(item.reminder.title, repo.reminders[index].title, "Title of index \(index) dosn't match")
            XCTAssertEqual(item.reminder.content, repo.reminders[index].content, "Content of index \(index) dosn't match")
            XCTAssertEqual(item.reminder.imageData, repo.reminders[index].imageData, "ImageData of index \(index) dosn't match")
            XCTAssertEqual(item.reminder.date, repo.reminders[index].date, "Date of index \(index) dosn't match")
        }
        
    }
    
    func test_whenRemindersRepositoryContainsExpiredReminders_thenViewModelHasExpiredItems() throws {
        // given
        let repo = RemindersRepositoryMock()
        repo.expectation = self.expectation(description: "Should contain 3 expired items")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        repo.reminders = [
            Reminder(title: "T1", content: "C1", imageData: nil, date: yesterday),
            Reminder(title: "T2", content: "C2", imageData: nil, date: yesterday),
            Reminder(title: "T3", content: "C3", imageData: nil, date: yesterday),
            Reminder(title: "T4", content: "C4", imageData: nil, date: Date().advanced(by: 180)),
        ]
        let viewModel = DefaultRemindersListViewModel(storage: repo)
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(viewModel.hasExpiredItemsCount == 3)
        XCTAssertTrue(viewModel.hasExpiredItems)
    }
    
    func test_whenDeleteAllRemindersIsReceived_thenCallStorageDeleteAllReminders() throws {
        // given
        let repo = RemindersRepositoryMock()
        repo.expectation = self.expectation(description: "ViewModel contain 4 reminders")
        repo.reminders = [
            Reminder(title: "T1", content: "C1", imageData: nil, date: nil),
            Reminder(title: "T2", content: "C2", imageData: nil, date: nil),
            Reminder(title: "T3", content: "C3", imageData: nil, date: nil),
            Reminder(title: "T4", content: "C4", imageData: nil, date: nil),
        ]
        let viewModel = DefaultRemindersListViewModel(storage: repo)
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(viewModel.items.value.count, 4)
        
        // when
        repo.expectation = self.expectation(description: "ViewModel contains zero reminders")
        viewModel.deleteAllReminders()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(repo.reminders.isEmpty)
        XCTAssertTrue(viewModel.isEmpty)
    }
    
    func test_whenDeleteOldRemindersIsReceived_thenCallStorageDeleteOldReminders() throws {
        // given
        let repo = RemindersRepositoryMock()
        repo.expectation = self.expectation(description: "ViewModel contain 4 reminders")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        repo.reminders = [
            Reminder(title: "T1", content: "C1", imageData: nil, date: yesterday),
            Reminder(title: "T2", content: "C2", imageData: nil, date: Date().advanced(by: 3600)),
            Reminder(title: "T3", content: "C3", imageData: nil, date: Date().advanced(by: 3600)),
            Reminder(title: "T4", content: "C4", imageData: nil, date: Date().advanced(by: 3600)),
        ]
        let viewModel = DefaultRemindersListViewModel(storage: repo)
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(viewModel.items.value.count, 4)
        
        // when
        repo.expectation = self.expectation(description: "ViewModel contains 3")
        viewModel.deleteOldReminders()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(repo.reminders.count == 3)
    }
    
    func test_wheneDeleteItemIsReceived_thenCallStorageDeleteReminder() throws {
        // given
        let repo = RemindersRepositoryMock()
        repo.expectation = self.expectation(description: "ViewModel contain 2 reminders")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        repo.reminders = [
            Reminder(title: "T1", content: "C1", imageData: nil, date: yesterday),
            Reminder(title: "T2", content: "C2", imageData: nil, date: Date().advanced(by: 3600))
        ]
        let viewModel = DefaultRemindersListViewModel(storage: repo)
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(viewModel.items.value.count, 2)
        
        // when
        let reminderID = viewModel.items.value[0].reminder.identifier
        repo.expectation = self.expectation(description: "ViewModel contains 3")
        viewModel.deleteItem(at: 0)
        
        // then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(repo.reminders.contains { $0.identifier == reminderID } == false )
    }

}
