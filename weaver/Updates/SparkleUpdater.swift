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

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}


