//
//  ConnectionQueueTests.swift
//  SQift
//
//  Created by Dave Camp on 8/11/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation
import SQift
import XCTest

class ConnectionQueueTestCase: XCTestCase {
    let connectionType: Connection.ConnectionType = {
        let path = NSFileManager.cachesDirectory.stringByAppendingString("/database_queue_tests.db")
        return .OnDisk(path)
    }()

    // MARK: - Setup and Teardown

    override func tearDown() {
        super.tearDown()
        NSFileManager.removeItemAtPath(connectionType.path)
    }

    // MARK: - Tests

    func testThatDatabaseQueueCanExecuteStatements() {
        do {
            // Given
            let queue = try ConnectionQueue(connection: Connection(connectionType: connectionType))

            var rowCount: Int64 = 0

            // When, Then
            try queue.execute { database in
                try database.execute("DROP TABLE IF EXISTS agents")
                try database.execute("CREATE TABLE agents(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, job TEXT)")
                try database.run("INSERT INTO agents(name, job) VALUES(?, ?)", "Sterling Archer", "World's Greatest Secret Agent")
                try database.run("INSERT INTO agents(name, job) VALUES(?, ?)", "Lana Kane", "Top Agent")

                rowCount = try database.query("SELECT count(*) FROM agents")
            }

            // Then
            XCTAssertEqual(rowCount, 2, "row count should be 2")
        } catch {
            XCTFail("Test Encountered Unexpected Error: \(error)")
        }
    }

    func testThatDatabaseQueueCanExecuteStatementsInTransaction() {
        do {
            // Given
            let queue = try ConnectionQueue(connection: Connection(connectionType: connectionType))

            var rowCount: Int64 = 0

            // When, Then
            try queue.executeInTransaction { database in
                try database.execute("DROP TABLE IF EXISTS agents")
                try database.execute("CREATE TABLE agents(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, job TEXT)")
                try database.run("INSERT INTO agents(name, job) VALUES(?, ?)", "Sterling Archer", "World's Greatest Secret Agent")
                try database.run("INSERT INTO agents(name, job) VALUES(?, ?)", "Lana Kane", "Top Agent")

                rowCount = try database.query("SELECT count(*) FROM agents")
            }

            // Then
            XCTAssertEqual(rowCount, 2, "row count should be 2")
        } catch {
            XCTFail("Test Encountered Unexpected Error: \(error)")
        }
    }

    func testThatDatabaseQueueCanExecuteStatementsInSavepoint() {
        do {
            // Given
            let queue = try ConnectionQueue(connection: Connection(connectionType: connectionType))

            var rowCount: Int64 = 0

            // When, Then
            try queue.executeInSavepoint("savepoint name with spaces") { database in
                try database.execute("DROP TABLE IF EXISTS agents")
                try database.execute("CREATE TABLE agents(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, job TEXT)")
                try database.run("INSERT INTO agents(name, job) VALUES(?, ?)", "Sterling Archer", "World's Greatest Secret Agent")
                try database.run("INSERT INTO agents(name, job) VALUES(?, ?)", "Lana Kane", "Top Agent")

                rowCount = try database.query("SELECT count(*) FROM agents")
            }

            // Then
            XCTAssertEqual(rowCount, 2, "row count should be 2")
        } catch {
            XCTFail("Test Encountered Unexpected Error: \(error)")
        }
    }
}
