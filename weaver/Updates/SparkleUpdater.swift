import Foundation
import SwiftUI
import Sparkle

@MainActor
final class SparkleUpdater: ObservableObject {
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    private let feedDelegate = SparkleFeedDelegate()

    init() {
        updaterController.updater.delegate = feedDelegate
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

private final class SparkleFeedDelegate: NSObject, SPUUpdaterDelegate {
    func feedURLString(for updater: SPUUpdater) -> String? {
        // Point to the latest release appcast asset
        return "https://github.com/jack-chaudier/weaver/releases/latest/download/appcast.xml"
    }
}


