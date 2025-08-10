import SwiftUI

struct EditorView: View {
    @EnvironmentObject private var appModel: AppModel
    let projectId: UUID
    let documentId: UUID
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(documentTitle)
                    .font(.headline)
                    .foregroundStyle(appModel.theme.accent)
                Spacer()
                Text(wordAndCharCount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            TextEditor(text: $text)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .scrollContentBackground(.hidden)
                .background(appModel.theme.background)
                .foregroundColor(appModel.theme.text)
                .padding()
                .onChange(of: text) { _, newValue in
                    appModel.updateDocumentContent(documentId, projectId: projectId, content: newValue)
                }
                .onAppear {
                    text = documentContent
                }
        }
        .background(appModel.theme.background)
    }

    private var documentTitle: String {
        appModel.documents(for: projectId).first(where: { $0.id == documentId })?.title ?? "Untitled"
    }

    private var documentContent: String {
        appModel.documents(for: projectId).first(where: { $0.id == documentId })?.content ?? ""
    }

    private var wordAndCharCount: String {
        let words = text.split { $0.isWhitespace || $0.isNewline }.count
        return "\(words) words · \(text.count) chars"
    }
}


