import SwiftUI
import SwiftData

struct TabNavigationView: View {
    @State private var selectedTab = 0
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ProblemListView()
                .tabItem {
                    Label("Problems", systemImage: "list.bullet.clipboard")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(appTheme?.primaryColor ?? .cyan)
    }
}

#Preview {
    TabNavigationView()
        .modelContainer(DataStore.createModelContainer())
}
