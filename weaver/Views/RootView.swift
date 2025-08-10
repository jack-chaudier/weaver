import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var updater = InAppUpdater()
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
        .environmentObject(updater)
        .environmentObject(sparkle)
        .onAppear { updater.checkAtLaunchOnce() }
        .alert(isPresented: $updater.isShowingUpdateAlert) {
            Alert(
                title: Text("Update Available \(updater.availableVersionTag ?? "")"),
                message: Text("A new version is available. Open the download page?"),
                primaryButton: .default(Text("Open")) { updater.openDownload() },
                secondaryButton: .cancel()
            )
        }
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


