import XCTest
@testable import TodoLost

final class TodoItemTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    // MARK: - Item to JSON Serialization
    
    func test_itemToJSON_withUserID_shouldAllDataSerialization() {
        // Given
        let itemSUT = TodoItem(
            id: "foo",
            text: "bar",
            importance: .important,
            deadline: Date.distantFuture,
            isDone: false,
            dateCreated: Date.distantPast,
            dateEdited: Date.now
        )
        
        // When
        let json = itemSUT.json
        guard let jsonDictionary = json as? [String: Any] else {
            XCTFail("Failed to serialize item to JSON")
            return
        }
        
        // Then
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.id] as? String, itemSUT.id)
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.text] as? String, itemSUT.text)
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.importance] as? String, itemSUT.importance.rawValue)
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.deadline] as? Int, Int(itemSUT.deadline!.timeIntervalSince1970))
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.isDone] as? Bool, itemSUT.isDone)
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.dateCreated] as? Int, Int(itemSUT.dateCreated.timeIntervalSince1970))
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.dateEdited] as? Int, Int(itemSUT.dateEdited!.timeIntervalSince1970))
    }
    
    func test_itemToJSON_withDefaultParam_shouldDateCreatedWithCurrentDate() {
        // Given
        let itemSUT = TodoItem(
            text: "foo",
            importance: .important,
            deadline: Date.now,
            isDone: false,
            dateEdited: nil
        )
        let currentData = Date()
        
        // When
        let json = itemSUT.json
        guard let jsonDictionary = json as? [String: Any] else {
            XCTFail("Failed to serialize item to JSON")
            return
        }
        
        // Then
        XCTAssertEqual(jsonDictionary[TodoItem.JsonKey.dateCreated] as? Int, Int(currentData.timeIntervalSince1970))
    }
    
    func test_itemToJSON_importanceSetToNormal_shouldImportanceNotSave() {
        // Given
        let itemSUT = TodoItem(
            text: "foo",
            importance: .important,
            deadline: Date.now,
            isDone: false,
            dateEdited: nil
        )
        
        // When
        let json = itemSUT.json
        guard let jsonDictionary = json as? [String: Any] else {
            XCTFail("Failed to serialize item to JSON")
            return
        }
        
        // Then
        XCTAssertNil(jsonDictionary[TodoItem.JsonKey.importance] as? Int)
    }
    
    func test_itemToJSON_deadlineNotSet_shouldDeadlineNotSave() {
        // Given
        let itemSUT = TodoItem(
            text: "foo",
            importance: .low,
            isDone: false,
            dateEdited: nil
        )
        
        // When
        let json = itemSUT.json
        guard let jsonDictionary = json as? [String: Any] else {
            XCTFail("Failed to serialize item to JSON")
            return
        }
        
        // Then
        XCTAssertNil(jsonDictionary[TodoItem.JsonKey.deadline] as? Int)
    }
    
    // MARK: - JSON Serialization to item
    
    func test_parse_shouldAllDataSerialization() {
        // Given
        let dataSUT = makeData(.json)
        var itemSUT: TodoItem?
        
        var jsonId: String = ""
        var jsonText: String = ""
        var jsonImportance: String = ""
        var jsonDeadline: Int?
        var jsonIsDone: Bool = false
        var jsonDateCreated: Int = 1
        var jsonDateEdited: Int?
        
        // When
        do {
            if let json = try JSONSerialization.jsonObject(with: dataSUT!, options: []) as? [String: Any],
               let jsonItems = json["todoItems"] as? [[String: Any]] {
                itemSUT = TodoItem.parse(json: jsonItems.first!)!
                
                jsonId = jsonItems.first?[TodoItem.JsonKey.id] as? String ?? ""
                jsonText = jsonItems.first?[TodoItem.JsonKey.text] as? String ?? ""
                jsonImportance = jsonItems.first?[TodoItem.JsonKey.importance] as? String ?? ""
                jsonDeadline = jsonItems.first?[TodoItem.JsonKey.deadline] as? Int
                jsonIsDone = jsonItems.first?[TodoItem.JsonKey.isDone] as? Bool ?? true
                jsonDateCreated = jsonItems.first?[TodoItem.JsonKey.dateCreated] as? Int ?? 1
                jsonDateEdited = jsonItems.first?[TodoItem.JsonKey.dateEdited] as? Int
            }
        } catch {
            XCTFail("Failed to serialize data to JSON")
        }
        
        // Then
        XCTAssertEqual(jsonId, itemSUT?.id)
        XCTAssertEqual(jsonText, itemSUT?.text)
        XCTAssertEqual(jsonImportance, itemSUT?.importance.rawValue)
        if let deadline = itemSUT?.deadline {
            XCTAssertEqual(jsonDeadline, Int(deadline.timeIntervalSince1970))
        } else {
            XCTAssertNil(jsonDeadline)
        }
        XCTAssertEqual(jsonIsDone, itemSUT?.isDone)
        XCTAssertEqual(jsonDateCreated, Int((itemSUT?.dateCreated.timeIntervalSince1970)!))
        if let dateEdited = itemSUT?.dateEdited {
            XCTAssertEqual(jsonDateEdited, Int(dateEdited.timeIntervalSince1970))
        } else {
            XCTAssertNil(jsonDateEdited)
        }
    }
    
    // MARK: - Item to CSV Serialization
    
    func test_itemToCSV_withUserID_shouldAllDataSerialization() {
        // Given
        let itemSUT = TodoItem(
            id: "foo",
            text: "bar",
            importance: .important,
            deadline: Date(),
            isDone: false,
            dateCreated: Date.distantPast,
            dateEdited: nil
        )
        
        // When
        let csv = itemSUT.csv
        
        let csvRows = csv.split(separator: "\n")
        
        let csvHeader = csvRows.first
        let csvValues = csvRows[1].split(separator: ",")
        
        var expectedFields = [
            itemSUT.id,
            itemSUT.text,
            itemSUT.importance.rawValue
        ]
        
        if itemSUT.deadline != nil {
            expectedFields.append(String(Int(itemSUT.deadline!.timeIntervalSince1970)))
        }
        
        expectedFields.append(String(itemSUT.isDone))
        expectedFields.append(String(Int(itemSUT.dateCreated.timeIntervalSince1970)))
        
        if itemSUT.dateEdited != nil {
            expectedFields.append(String(Int(itemSUT.dateEdited!.timeIntervalSince1970)))
        }
        
        // Then
        XCTAssertEqual(csvRows.count, 2)
        
        XCTAssertEqual(csvHeader, "\(TodoItem.JsonKey.id),\(TodoItem.JsonKey.text),\(TodoItem.JsonKey.importance),\(TodoItem.JsonKey.deadline),\(TodoItem.JsonKey.isDone),\(TodoItem.JsonKey.dateCreated),\(TodoItem.JsonKey.dateEdited)")
        
        XCTAssertEqual(csvValues.count, expectedFields.count)
        
        for (index, value) in csvValues.enumerated() {
            XCTAssertEqual(String(value), expectedFields[index])
        }
    }
    
    // MARK: - CSV Serialization to item
    
    func test_parse_csv_shouldAllDataSerialization() {
        // Given
        let dataSUT = makeData(.csv)
        var itemSUT: TodoItem?
        
        // When
        let csvString = String(data: dataSUT!, encoding: .utf8)!
        let csvRows = csvString.split(separator: "\n").map { String($0) }
        let csvValues = csvRows[1].split(separator: ",")
        
        var expectedFields = [String]()
        
        if let csvFields = csvRows.last?.split(separator: ",").map({ String($0) }) {
            itemSUT = TodoItem.parse(csv: csvString)
            
            expectedFields.append(itemSUT!.id)
            expectedFields.append(itemSUT!.text)
            expectedFields.append(itemSUT!.importance.rawValue)
            
            if itemSUT!.deadline != nil {
                expectedFields.append(String(Int(itemSUT!.deadline!.timeIntervalSince1970)))
            }
            
            expectedFields.append(String(itemSUT!.isDone))
            expectedFields.append(String(Int(itemSUT!.dateCreated.timeIntervalSince1970)))
            
            if itemSUT!.dateEdited != nil {
                expectedFields.append(String(Int(itemSUT!.dateEdited!.timeIntervalSince1970)))
            }
        }
        
        // Then
        XCTAssertEqual(csvRows.count, 2)
        XCTAssertEqual(csvValues.count, expectedFields.count)
        
        for (index, value) in csvValues.enumerated() {
            XCTAssertEqual(String(value), expectedFields[index])
        }
    }

    
    // MARK: - Private
    
    private enum TypeFile: String {
        case json
        case csv
    }
    
    private func makeData(_ type: TypeFile) -> Data? {
        var jsonData: Data?
        
        guard let jsonFile = Bundle.main.path(
            forResource: "TodoItems",
            ofType: type.rawValue
        ) else {
            XCTFail("file not found")
            fatalError()
        }
        
        do {
            guard let data = try String(contentsOfFile: jsonFile).data(using: .utf8) else {
                XCTFail("File could not be converted to Data")
                fatalError()
            }
            
            jsonData = data
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        return jsonData
    }
}
