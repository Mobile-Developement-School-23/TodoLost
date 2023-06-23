//
//  FileCacheTests.swift
//  TodoLostTests
//
//  Created by Дмитрий Данилин on 12.06.2023.
//

import XCTest
import DTLogger
@testable import TodoLost

final class FileCacheTests: XCTestCase {
    var fileCache: IFileCache?
    let fileName = "Foo"
    
    let items = [
        TodoItem(
            text: "Foo",
            importance: .low,
            isDone: false
        ),
        TodoItem(
            id: "Foo",
            text: "Foo, bar, baz",
            importance: .normal,
            deadline: .distantFuture,
            isDone: false,
            dateCreated: .distantPast,
            dateEdited: .now
        )
    ]

    override func setUp() {
        super.setUp()
        
        fileCache = FileCache()
        items.forEach({ createSavedTestDataToJSON($0) })
        items.forEach({ createSavedTestDataToCSV($0) })
    }
    
    override func tearDown() {
        super.tearDown()
        
        fileCache?.items.forEach { (id, _) in
            fileCache?.deleteFromCache(id)
        }
        fileCache = nil
    }
    
    // MARK: - Tests cache
    
    func test_add_shouldItemsNotEmpty() {
        // Given
        var items: [String: TodoItem] = [:]
        let item = TodoItem(
            text: "Foo",
            importance: .low,
            isDone: false
        )
        
        // When
        fileCache?.addToCache(item)
        items = fileCache?.items ?? [:]
        
        // Then
        XCTAssertFalse(items.isEmpty)
    }
    
    func test_delete_shouldItemsIsEmpty() {
        // Given
        var items: [String: TodoItem] = [:]
        let item = TodoItem(
            text: "Foo",
            importance: .low,
            isDone: false
        )
        
        // When
        fileCache?.addToCache(item)
        fileCache?.items.forEach({ (id, _) in
            fileCache?.deleteFromCache(id)
        })
        
        items = fileCache?.items ?? [:]
        
        // Then
        XCTAssertTrue(items.isEmpty)
    }
    
    // MARK: - Storage for json
    
    func test_saveToStorageJSON_shouldNotErrors() {
        // Given
        var saveError: Error?
        let item = TodoItem(
            text: "Foo",
            importance: .low,
            isDone: false
        )
        
        // When
        fileCache?.addToCache(item)
        
        do {
            try fileCache?.saveToStorage(jsonFileName: fileName)
        } catch {
            saveError = error
        }
        
        // Then
        XCTAssertNil(saveError)
    }
    
    func test_loadFromStorageJSON_shouldLoadItemsToCache() {
        // Given
        var items: [String: TodoItem] = [:]
        
        // When
        do {
            try fileCache?.loadFromStorage(jsonFileName: fileName)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        items = fileCache?.items ?? [:]
        
        // Then
        XCTAssertFalse(items.isEmpty)
        XCTAssertGreaterThanOrEqual(items.count, 2)
    }
    
    func test_loadFromStorageJSON_wrongFilename_shouldErrorFileNotFound() {
        // Given
        var errorSUT: Error?
        
        // When
        do {
            try fileCache?.loadFromStorage(jsonFileName: "Bar")
        } catch {
            errorSUT = error
        }
        
        // Then
        XCTAssertNotNil(errorSUT)
    }
    
    // MARK: - Storage for csv
    
    func test_SaveToStorageCSV_shouldNotErrors() {
        // Given
        var saveError: Error?
        let item = TodoItem(
            text: "Foo, bar, baz",
            importance: .low,
            isDone: false
        )
        
        // When
        fileCache?.addToCache(item)
        
        do {
            try fileCache?.saveToStorage(csvFileName: fileName)
        } catch {
            saveError = error
        }
        
        // Then
        XCTAssertNil(saveError)
    }
    
    func test_loadFromStorageCSV_shouldLoadItemsToCache() {
        // Given
        var items: [String: TodoItem] = [:]
        
        // When
        do {
            try fileCache?.loadFromStorage(csvFileName: fileName)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        items = fileCache?.items ?? [:]
        
        SystemLogger.info(items.description)
        
        // Then
        XCTAssertFalse(items.isEmpty)
        XCTAssertGreaterThanOrEqual(items.count, 2)
    }
    
    func test_loadFromStorageCSV_wrongFilename_shouldErrorFileNotFound() {
        // Given
        var errorSUT: Error?
        
        // When
        do {
            try fileCache?.loadFromStorage(csvFileName: "Bar")
        } catch {
            errorSUT = error
        }
        
        // Then
        XCTAssertNotNil(errorSUT)
    }
    
    // MARK: - Private method
    
    private func createSavedTestDataToJSON(_ item: TodoItem) {
        fileCache?.addToCache(item)

        do {
            try fileCache?.saveToStorage(jsonFileName: fileName)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    private func createSavedTestDataToCSV(_ item: TodoItem) {
        fileCache?.addToCache(item)

        do {
            try fileCache?.saveToStorage(csvFileName: fileName)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
