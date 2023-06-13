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
            importance: .normal,
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
        XCTAssertNil(jsonDictionary[TodoItem.JsonKey.importance])
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
        XCTAssertNil(jsonDictionary[TodoItem.JsonKey.deadline])
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
            deadline: .now,
            isDone: false,
            dateCreated: .distantPast,
            dateEdited: .distantFuture
        )
        
        // When
        let csv = itemSUT.csv
        let parseData = TodoItem.parse(csv: csv)
        
        // Then
        XCTAssertEqual(itemSUT.id, parseData?.id)
        XCTAssertEqual(itemSUT.text, parseData?.text)
        XCTAssertEqual(itemSUT.importance, parseData?.importance)
        if let deadlineSUT = itemSUT.deadline, let deadline = parseData?.deadline {
            XCTAssertEqual(deadlineSUT.timeIntervalSince1970, deadline.timeIntervalSince1970, accuracy: 1)
        } else {
            XCTAssertEqual(itemSUT.deadline, parseData?.deadline)
        }
        XCTAssertEqual(itemSUT.isDone, parseData?.isDone)
        if let dateCreated = parseData?.dateCreated.timeIntervalSince1970 {
            XCTAssertEqual(itemSUT.dateCreated.timeIntervalSince1970, dateCreated, accuracy: 1)
        } else {
            XCTAssertEqual(itemSUT.dateCreated.timeIntervalSince1970, parseData?.dateCreated.timeIntervalSince1970)
        }
        
        if let dateEditedSUT = itemSUT.dateEdited, let dateEdited = parseData?.dateEdited {
            XCTAssertEqual(dateEditedSUT.timeIntervalSince1970, dateEdited.timeIntervalSince1970, accuracy: 1)
        } else {
            XCTAssertEqual(itemSUT.dateEdited, parseData?.dateEdited)
        }
    }
    
    func test_itemToCSV_importanceSetToNormal_shouldImportanceNotSave() {
        // Given
        let itemSUT = TodoItem(
            text: "foo",
            importance: .normal,
            deadline: Date.now,
            isDone: false,
            dateEdited: nil
        )
        
        // When
        let csv = itemSUT.csv
        let csvRows = csv.split(separator: "\n")
        let csvHeader = csvRows[0].components(separatedBy: ",")
        let csvValues = csvRows[1].components(separatedBy: ",")
        
        guard let importanceIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.importance) else {
            XCTFail()
            return
        }
        
        let importance = csvValues[importanceIndex]
        
        // Then
        XCTAssertEqual(importance, "")
    }
    
    
    // MARK: - CSV Serialization to item
    
    func test_parse_csv_shouldAllDataSerialization() {
        // Given
        let dataSUT = makeData(.csv)
        var itemSUT: TodoItem?
        
        // When
        let csvString = String(data: dataSUT!, encoding: .utf8)!
        let csvRows = csvString.split(separator: "\n")
        let csvHeader = csvRows[0].components(separatedBy: ",")
        let csvValues = csvRows[1].components(separatedBy: ",")
        
        guard
            let idIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.id),
            let textIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.text),
            let importanceIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.importance),
            let deadlineIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.deadline),
            let isDoneIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.isDone),
            let dateCreatedIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.dateCreated),
            let dateEditedIndex = csvHeader.firstIndex(of: TodoItem.JsonKey.dateEdited)
        else {
            XCTFail()
            return
        }
        
        let id = csvValues[idIndex]
        let text = csvValues[textIndex].replacingOccurrences(of: "|", with: ",")
        let importance = csvValues[importanceIndex]
        let deadline = csvValues[deadlineIndex]
        let isDone = csvValues[isDoneIndex]
        let dateCreated = csvValues[dateCreatedIndex]
        let dateEdited = csvValues[dateEditedIndex]
        
        itemSUT = TodoItem.parse(csv: csvString)
        
        // Then
        XCTAssertEqual(itemSUT?.id, id)
        XCTAssertEqual(itemSUT?.text, text)
        XCTAssertEqual(itemSUT?.importance.rawValue, importance)
        XCTAssertEqual(itemSUT?.deadline?.timeIntervalSince1970, TimeInterval(deadline))
        XCTAssertEqual(itemSUT?.isDone, Bool(isDone))
        XCTAssertEqual(itemSUT?.dateCreated.timeIntervalSince1970, TimeInterval(dateCreated))
        XCTAssertEqual((itemSUT?.dateEdited?.timeIntervalSince1970), TimeInterval(dateEdited))
    }

    
    // MARK: - Private
    
    private enum TypeFile: String {
        case json
        case csv
    }
    
    private func makeData(_ type: TypeFile) -> Data? {
        var jsonData: Data?
        
        guard let testBundle = Bundle(identifier: "ru.zyfunphoto.TodoLostTests") else {
            XCTFail("test bundle not found")
            return nil
        }
        
        guard let filePath = testBundle.path(forResource: "TodoItems", ofType: type.rawValue) else {
            XCTFail("file not found")
            return nil
        }
        
        do {
            guard let data = try String(contentsOfFile: filePath).data(using: .utf8) else {
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
