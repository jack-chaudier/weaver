import SwiftUI

struct ProjectNavigatorView: View {
    @EnvironmentObject private var appModel: AppModel
    let projectId: UUID
    @State private var newDocTitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(projectTitle).font(.title2).bold()
                Spacer()
                Button {
                    appModel.createDocument(in: projectId, titled: newDocTitle.isEmpty ? "Untitled" : newDocTitle)
                    newDocTitle = ""
                } label: {
                    Label("New Doc", systemImage: "doc.badge.plus")
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }

            HStack {
                TextField("Document title", text: $newDocTitle)
                    .textFieldStyle(.roundedBorder)
                Spacer()
            }

            List(selection: $appModel.selectedDocumentId) {
                ForEach(appModel.documents(for: projectId)) { doc in
                    Text(doc.title)
                        .tag(doc.id)
                        .contextMenu {
                            Button("Rename") { rename(doc) }
                            Button(role: .destructive) { appModel.deleteDocument(doc.id, projectId: projectId) } label: { Text("Delete") }
                        }
                        .onTapGesture {
                            appModel.selectedDocumentId = doc.id
                        }
                }
            }
        }
        .padding()
    }

    private var projectTitle: String {
        appModel.projects.first(where: { $0.id == projectId })?.name ?? "Project"
    }

    private func rename(_ doc: DocumentFile) {
        let newTitle = doc.title + " Copy"
        appModel.renameDocument(doc.id, projectId: projectId, to: newTitle)
    }
}


