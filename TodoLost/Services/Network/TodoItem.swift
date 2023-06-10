import Foundation

enum Importance {
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
        deadline: Date?,
        isDone: Bool,
        dateCreated: Date = Date(),
        dateEdited: Date?
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
