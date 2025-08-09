import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var newProjectName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Library").font(.largeTitle).bold()
                Spacer()
                Button {
                    withAnimation {
                        appModel.createProject(named: newProjectName.isEmpty ? "New Project" : newProjectName)
                        newProjectName = ""
                    }
                } label: {
                    Label("New Project", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
            HStack {
                TextField("Project name", text: $newProjectName)
                    .textFieldStyle(.roundedBorder)
                Spacer()
            }

            List(selection: $appModel.selectedProjectId) {
                ForEach(appModel.projects) { project in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(project.name).font(.headline)
                            Text(project.updatedAt, style: .date).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .contextMenu {
                        Button("Rename") { promptRename(project) }
                        Button(role: .destructive) { appModel.deleteProject(project.id) } label: { Text("Delete") }
                    }
                    .tag(project.id)
                    .onTapGesture {
                        appModel.selectedProjectId = project.id
                    }
                }
            }
        }
        .padding()
    }

    private func promptRename(_ project: Project) {
        // Minimal inline rename via sheet could be added; keep simple for now.
        let newName = project.name + " Copy"
        appModel.renameProject(project.id, to: newName)
    }
}


