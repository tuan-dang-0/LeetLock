//
//  LeetLockApp.swift
//  LeetLock
//
//  Created by Tuan Dang on 1/3/26.
//

import SwiftUI
import SwiftData

@main
struct LeetLockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(DataStore.shared)
        }
    }
}
