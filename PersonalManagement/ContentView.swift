import SwiftUI

struct ContentView: View {
    @State private var hasStartedApp = false

    var body: some View {
        if hasStartedApp {
            TabView {
                PomodoroView()
                    .tabItem {
                        Label("Pomodoro", systemImage: "timer")
                    }
                    .tag(0)

                TodoView()
                    .tabItem {
                        Label("To-Do", systemImage: "checkmark.circle")
                    }
                    .tag(1)
            }
            .accentColor(.blue) // Set tab bar accent color
        } else {
            HomeView(isAppStarted: $hasStartedApp)
        }
    }
}
