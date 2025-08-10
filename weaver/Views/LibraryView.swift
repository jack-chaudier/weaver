import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var newProjectName: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Library").font(.largeTitle).bold()
                    Spacer()
                    HStack(spacing: 8) {
                        TextField("Name your project", text: $newProjectName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 260)
                        Button {
                            withAnimation {
                                appModel.createProject(named: newProjectName)
                                newProjectName = ""
                            }
                        } label: {
                            Label("Create", systemImage: "plus")
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(appModel.projects) { project in
                        ProjectCard(project: project)
                            .onTapGesture { appModel.selectedProjectId = project.id }
                            .contextMenu {
                                Button("Rename") { promptRename(project) }
                                Button(role: .destructive) { appModel.deleteProject(project.id) } label: { Text("Delete") }
                            }
                    }
                    NewProjectCard {
                        withAnimation { appModel.createProject(named: newProjectName) }
                        newProjectName = ""
                    }
                }
            }
            .padding(20)
        }
    }

    private func promptRename(_ project: Project) {
        // Minimal inline rename via sheet could be added; keep simple for now.
        let newName = project.name + " Copy"
        appModel.renameProject(project.id, to: newName)
    }
}

private struct ProjectCard: View {
    let project: Project
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .lineLimit(2)
            Text(project.updatedAt, style: .date)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct NewProjectCard: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.app")
                    .font(.system(size: 28, weight: .regular, design: .monospaced))
                Text("New Project")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor.opacity(0.08)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [6]))
            )
        }
        .buttonStyle(.plain)
    }
}


