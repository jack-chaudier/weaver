import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    // Storage
    @Published private(set) var projects: [Project] = []
    @Published private(set) var documentsByProjectId: [UUID: [DocumentFile]] = [:]

    // UI State
    @Published var selectedProjectId: UUID? = nil
    @Published var selectedDocumentId: UUID? = nil
    @Published var theme: EditorTheme = .dark

    // File locations
    private let fileManager = FileManager.default
    private let baseDirectoryURL: URL

    init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleId = Bundle.main.bundleIdentifier ?? "weaver"
        let base = appSupport.appendingPathComponent(bundleId, isDirectory: true)
        baseDirectoryURL = base
        createAppDirectoriesIfNeeded()
        loadAll()
    }

    // MARK: - Public API
    func createProject(named name: String) {
        var project = Project(name: name)
        projects.append(project)
        documentsByProjectId[project.id] = [DocumentFile(projectId: project.id, title: "Untitled")]
        persistProjectList()
        persistDocuments(for: project.id)
        selectedProjectId = project.id
        selectedDocumentId = documentsByProjectId[project.id]?.first?.id
    }

    func renameProject(_ projectId: UUID, to newName: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].name = newName
        projects[index].updatedAt = Date()
        persistProjectList()
    }

    func deleteProject(_ projectId: UUID) {
        projects.removeAll { $0.id == projectId }
        documentsByProjectId[projectId] = nil
        persistProjectList()
        deleteProjectDirectory(projectId)
        if selectedProjectId == projectId { selectedProjectId = nil; selectedDocumentId = nil }
    }

    func createDocument(in projectId: UUID, titled title: String) {
        let doc = DocumentFile(projectId: projectId, title: title)
        documentsByProjectId[projectId, default: []].append(doc)
        persistDocuments(for: projectId)
        selectedDocumentId = doc.id
    }

    func updateDocumentContent(_ documentId: UUID, projectId: UUID, content: String) {
        guard var docs = documentsByProjectId[projectId], let idx = docs.firstIndex(where: { $0.id == documentId }) else { return }
        docs[idx].content = content
        docs[idx].updatedAt = Date()
        documentsByProjectId[projectId] = docs
        persistDocuments(for: projectId)
    }

    func renameDocument(_ documentId: UUID, projectId: UUID, to newTitle: String) {
        guard var docs = documentsByProjectId[projectId], let idx = docs.firstIndex(where: { $0.id == documentId }) else { return }
        docs[idx].title = newTitle
        docs[idx].updatedAt = Date()
        documentsByProjectId[projectId] = docs
        persistDocuments(for: projectId)
    }

    func deleteDocument(_ documentId: UUID, projectId: UUID) {
        guard var docs = documentsByProjectId[projectId] else { return }
        docs.removeAll { $0.id == documentId }
        documentsByProjectId[projectId] = docs
        persistDocuments(for: projectId)
        if selectedDocumentId == documentId { selectedDocumentId = docs.first?.id }
    }

    func documents(for projectId: UUID) -> [DocumentFile] {
        documentsByProjectId[projectId] ?? []
    }

    // MARK: - Loading / Persistence
    private func createAppDirectoriesIfNeeded() {
        do {
            if !fileManager.fileExists(atPath: baseDirectoryURL.path) {
                try fileManager.createDirectory(at: baseDirectoryURL, withIntermediateDirectories: true)
            }
        } catch {
            print("Failed creating Application Support dir: \(error)")
        }
    }

    private func loadAll() {
        loadProjects()
        for project in projects {
            loadDocuments(for: project.id)
        }
        if selectedProjectId == nil { selectedProjectId = projects.first?.id }
        if let pid = selectedProjectId, selectedDocumentId == nil {
            selectedDocumentId = documentsByProjectId[pid]?.first?.id
        }
    }

    private func projectsURL() -> URL { baseDirectoryURL.appendingPathComponent("projects.json") }
    private func documentsURL(for projectId: UUID) -> URL { baseDirectoryURL.appendingPathComponent("\(projectId.uuidString).documents.json") }
    private func projectDirectoryURL(_ projectId: UUID) -> URL { baseDirectoryURL.appendingPathComponent(projectId.uuidString, isDirectory: true) }

    private func loadProjects() {
        let url = projectsURL()
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            projects = try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("Failed decoding projects: \(error)")
        }
    }

    private func loadDocuments(for projectId: UUID) {
        let url = documentsURL(for: projectId)
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            let docs = try JSONDecoder().decode([DocumentFile].self, from: data)
            documentsByProjectId[projectId] = docs
        } catch {
            print("Failed decoding documents: \(error)")
        }
    }

    private func persistProjectList() {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: projectsURL(), options: [.atomic])
        } catch {
            print("Failed saving projects: \(error)")
        }
    }

    private func persistDocuments(for projectId: UUID) {
        do {
            let docs = documentsByProjectId[projectId] ?? []
            let data = try JSONEncoder().encode(docs)
            try data.write(to: documentsURL(for: projectId), options: [.atomic])
        } catch {
            print("Failed saving documents: \(error)")
        }
    }

    private func deleteProjectDirectory(_ projectId: UUID) {
        let url = projectDirectoryURL(projectId)
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
        // Also delete docs JSON
        try? fileManager.removeItem(at: documentsURL(for: projectId))
    }
}


