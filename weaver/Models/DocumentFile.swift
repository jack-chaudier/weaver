import Foundation

struct DocumentFile: Identifiable, Codable, Hashable {
    let id: UUID
    var projectId: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), projectId: UUID, title: String, content: String = "", createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.projectId = projectId
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


