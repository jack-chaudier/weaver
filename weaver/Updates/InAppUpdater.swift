import Foundation
import SwiftUI

@MainActor
final class InAppUpdater: ObservableObject {
    struct ReleaseAsset: Decodable {
        let name: String
        let browser_download_url: URL
    }

    struct ReleaseResponse: Decodable {
        let tag_name: String
        let name: String?
        let body: String?
        let html_url: URL
        let assets: [ReleaseAsset]
    }

    @Published var availableVersionTag: String? = nil
    @Published var releaseNotes: String? = nil
    @Published var downloadURL: URL? = nil
    @Published var isShowingUpdateAlert: Bool = false

    private var hasCheckedThisSession = false

    func checkAtLaunchOnce() {
        guard !hasCheckedThisSession else { return }
        hasCheckedThisSession = true
        Task { await checkForUpdates(userInitiated: false) }
    }

    func checkForUpdates(userInitiated: Bool) async {
        guard let latest = await fetchLatestRelease() else {
            if userInitiated { showNoUpdateAlert() }
            return
        }

        let current = currentVersionTag()
        if isNewer(tag: latest.tag_name, than: current) {
            availableVersionTag = latest.tag_name
            releaseNotes = latest.body
            if let dmg = latest.assets.first(where: { $0.name.lowercased().hasSuffix(".dmg") })?.browser_download_url {
                downloadURL = dmg
            } else {
                downloadURL = latest.html_url
            }
            isShowingUpdateAlert = true
        } else if userInitiated {
            showNoUpdateAlert()
        }
    }

    func openDownload() {
        guard let url = downloadURL else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Helpers
    private func fetchLatestRelease() async -> ReleaseResponse? {
        let url = URL(string: "https://api.github.com/repos/jack-chaudier/weaver/releases/latest")!
        var req = URLRequest(url: url)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(ReleaseResponse.self, from: data)
        } catch {
            return nil
        }
    }

    private func currentVersionTag() -> String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        return "v\(short)"
    }

    private func isNewer(tag lhs: String, than rhs: String) -> Bool {
        // Expecting format vX.Y.Z; strip leading v and compare semver components
        func parse(_ t: String) -> [Int] {
            t.trimmingCharacters(in: CharacterSet(charactersIn: "v")).split(separator: ".").compactMap { Int($0) }
        }
        let a = parse(lhs)
        let b = parse(rhs)
        for i in 0..<max(a.count, b.count) {
            let ai = i < a.count ? a[i] : 0
            let bi = i < b.count ? b[i] : 0
            if ai != bi { return ai > bi }
        }
        return false
    }

    private func showNoUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date"
        alert.informativeText = "You already have the latest version installed."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}


