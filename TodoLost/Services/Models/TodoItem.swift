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
