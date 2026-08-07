//
//  ByensGaaderAdminApp.swift
//  ByensGaaderAdmin
//
//  Created by Jesper Hyldenbrandt Bjerre on 30/07/2026.
//

import SwiftUI

@main
struct ByensGaaderAdminApp: App {
    @State private var authentication = AdminAuthentication.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if authentication.state == .signedIn {
                    ContentView()
                } else {
                    AdminLoginView()
                }
            }
            .environment(authentication)
            .task {
                if authentication.state == .checking {
                    await authentication.restore()
                }
            }
        }
    }
}
