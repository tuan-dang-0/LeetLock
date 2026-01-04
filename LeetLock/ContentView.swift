//
//  ContentView.swift
//  LeetLock
//
//  Created by Tuan Dang on 1/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userSettingsArray: [UserSettings]
    @State private var isLoading = true
    
    private var userSettings: UserSettings? {
        userSettingsArray.first
    }
    
    private var shouldShowOnboarding: Bool {
        guard let settings = userSettings else { 
            print("📱 ContentView: No settings found, showing onboarding")
            return true 
        }
        let showOnboarding = !settings.hasCompletedOnboarding
        print("📱 ContentView: hasCompletedOnboarding = \(settings.hasCompletedOnboarding), showing onboarding = \(showOnboarding)")
        return showOnboarding
    }
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isLoading = false
                            }
                        }
                    }
            } else {
                if shouldShowOnboarding {
                    OnboardingContainerView()
                } else {
                    TabNavigationView()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            print("📱 ContentView appeared")
        }
    }
}
