import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationSplitView {
            LibraryView()
        } content: {
            if let projectId = appModel.selectedProjectId {
                ProjectNavigatorView(projectId: projectId)
            } else {
                Text("Select or create a project")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            if let pid = appModel.selectedProjectId, let did = appModel.selectedDocumentId {
                EditorView(projectId: pid, documentId: did)
            } else {
                Text("Select a document")
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar { ThemePicker() }
    }
}

struct ThemePicker: View {
    @EnvironmentObject private var appModel: AppModel
    var body: some View {
        Picker("Theme", selection: $appModel.theme) {
            ForEach(EditorTheme.allCases) { theme in
                Text(theme.name).tag(theme)
            }
        }
        .pickerStyle(.menu)
    }
}


