//
//  FileCacheTests.swift
//  TodoLostTests
//
//  Created by Дмитрий Данилин on 12.06.2023.
//

import XCTest
@testable import TodoLost

final class FileCacheTests: XCTestCase {
    var fileCache: IFileCache?
    let fileName = "Foo"

    override func setUp() {
        super.setUp()
        
        fileCache = FileCache()
        createSavedTestTodoItem()
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
    
    // MARK: - Tests FileManager
    
    func test_saveTo_shouldNotErrors() {
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
            try fileCache?.saveToStorage(fileName: fileName)
        } catch {
            saveError = error
        }
        
        // Then
        XCTAssertNil(saveError)
    }
    
    func test_loadFrom_shouldLoadItemsToCache() {
        // Given
        var items: [String: TodoItem] = [:]
        
        // When
        do {
            try fileCache?.loadFromStorage(fileName: fileName)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        items = fileCache?.items ?? [:]
        
        // Then
        XCTAssertFalse(items.isEmpty)
    }
    
    func test_loadFrom_wrongFilename_shouldErrorFileNotFound() {
        // Given
        var errorSUT: Error?
        
        // When
        do {
            try fileCache?.loadFromStorage(fileName: "Bar")
        } catch {
            errorSUT = error
        }
        
        // Then
        XCTAssertNotNil(errorSUT)
    }
    
    // MARK: - Private method
    
    private func createSavedTestTodoItem() {
        let item = TodoItem(
            text: "Foo",
            importance: .low,
            isDone: false
        )

        fileCache?.addToCache(item)

        do {
            try fileCache?.saveToStorage(fileName: fileName)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
