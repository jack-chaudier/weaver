//
//  weaverApp.swift
//  weaver
//
//  Created by Jack Gaffney on 8/9/25.
//

import SwiftUI

@main
struct weaverApp: App {
    @StateObject private var appModel = AppModel()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appModel)
        }
    }
}
