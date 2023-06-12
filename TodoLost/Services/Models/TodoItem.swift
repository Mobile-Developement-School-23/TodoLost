import Foundation

enum Importance: String {
    case low
    case normal
    case important
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateCreated: Date
    let dateEdited: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool,
        dateCreated: Date = Date(),
        dateEdited: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.dateCreated = dateCreated
        self.dateEdited = dateEdited
    }
}

// MARK: - Json data

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard
            let id = json[JsonKey.id] as? String,
            let text = json[JsonKey.text] as? String,
            let importanceString = json[JsonKey.importance] as? String,
            let isDone = json[JsonKey.isDone] as? Bool,
            let dateCreatedTimestamp = json[JsonKey.dateCreated] as? TimeInterval
            
        else { return nil}
        
        let importance = Importance(rawValue: importanceString) ?? .normal
        
        var deadline: Date?
        if let deadlineTimestamp = json[JsonKey.deadline] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        }
        
        var dateEdited: Date?
        if let dateEditedTimestamp = json[JsonKey.dateEdited] as? TimeInterval {
            dateEdited = Date(timeIntervalSince1970: dateEditedTimestamp)
        }
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreated: Date(timeIntervalSince1970: dateCreatedTimestamp),
            dateEdited: dateEdited
        )
        
        return item
    }
    
    var json: Any {
        var json: [String: Any] = [:]
        json[JsonKey.id] = id
        json[JsonKey.text] = text
        if importance != .normal {
            json[JsonKey.importance] = importance.rawValue
        }
        if let deadline {
            json[JsonKey.deadline] = Int(deadline.timeIntervalSince1970)
        }
        json[JsonKey.isDone] = isDone
        json[JsonKey.dateCreated] = Int(dateCreated.timeIntervalSince1970)
        if let dateEdited {
            json[JsonKey.dateEdited] = Int(dateEdited.timeIntervalSince1970)
        }
        
        return json
    }
}

// MARK: - CSV data

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let csvRows = csv.split(separator: "\n")
        guard csvRows.count > 1 else {
            return nil
        }
        
        let csvHeaderComponents = csvRows[0].components(separatedBy: ",")
        let csvValues = csvRows[1].split(separator: ",")
        
        guard
            let idIndex = csvHeaderComponents.firstIndex(of: JsonKey.id),
            let textIndex = csvHeaderComponents.firstIndex(of: JsonKey.text),
            let importanceIndex = csvHeaderComponents.firstIndex(of: JsonKey.importance),
            let isDoneIndex = csvHeaderComponents.firstIndex(of: JsonKey.isDone),
            let dateCreatedIndex = csvHeaderComponents.firstIndex(of: JsonKey.dateCreated)
        else {
            return nil
        }
        
        let id = String(csvValues[idIndex])
        let text = String(csvValues[textIndex])
        let importanceString = String(csvValues[importanceIndex])
        let importance = Importance(rawValue: importanceString) ?? .normal
        
        let isDoneString = String(csvValues[isDoneIndex])
        let isDone = isDoneString.lowercased() == "true"
        
        let dateCreatedTimestampString = String(csvValues[dateCreatedIndex])
        guard let dateCreatedTimestamp = TimeInterval(dateCreatedTimestampString) else {
            return nil
        }
        let dateCreated = Date(timeIntervalSince1970: dateCreatedTimestamp)
        
        var deadline: Date?
        if let deadlineIndex = csvHeaderComponents.firstIndex(of: JsonKey.deadline) {
            let deadlineTimestampString = String(csvValues[deadlineIndex])
            if let deadlineTimestamp = TimeInterval(deadlineTimestampString) {
                deadline = Date(timeIntervalSince1970: deadlineTimestamp)
            }
        }
        
        var dateEdited: Date?
        if let dateEditedIndex = csvHeaderComponents.firstIndex(of: JsonKey.dateEdited) {
            let dateEditedTimestampString = String(csvValues[dateEditedIndex])
            if let dateEditedTimestamp = TimeInterval(dateEditedTimestampString) {
                dateEdited = Date(timeIntervalSince1970: dateEditedTimestamp)
            }
        }
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        return item
    }
    
    var csv: String {
        var csv = "\(JsonKey.id),\(JsonKey.text),\(JsonKey.importance),\(JsonKey.deadline),\(JsonKey.isDone),\(JsonKey.dateCreated),\(JsonKey.dateEdited)\n"
        
        csv += "\(id),\(text),\(importance.rawValue),"
        if let deadline = deadline {
            csv += "\(Int(deadline.timeIntervalSince1970)),"
        } else {
            csv += ","
        }
        csv += "\(isDone),\(Int(dateCreated.timeIntervalSince1970)),"
        if let dateEdited = dateEdited {
            csv += "\(Int(dateEdited.timeIntervalSince1970))"
        }
        
        return csv
    }
}

// MARK: - Key

extension TodoItem {
    struct JsonKey {
        static let id = "id"
        static let text = "text"
        static let importance = "importance"
        static let deadline = "deadline"
        static let isDone = "isDone"
        static let dateCreated = "dateCreated"
        static let dateEdited = "dateEdited"
    }
}
