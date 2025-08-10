import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var sparkle = SparkleUpdater()

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
        .toolbar {
            ThemePicker()
            Button { sparkle.checkForUpdates() } label: { Label("Check for Updates", systemImage: "arrow.down.circle") }
        }
        .environmentObject(sparkle)
        .preferredColorScheme(appModel.theme.preferredColorScheme)
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


