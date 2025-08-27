# Habit Tracker — PersonalManagement

A simple SwiftUI app that helps build habits with two core tools:

- **To‑Do:** capture tasks, check them off, and keep momentum.
- **Pomodoro Timer:** focus in 25‑minute sprints with short breaks.

> This README documents the current structure shown in the project navigator (e.g., `PersonalManagementApp`, `TodoView`, `PomodoroView`) and provides setup and extension tips.

---

## Features

### ✅ To‑Do
- Add new tasks
- Toggle completion (check/undo)
- Delete tasks with swipe
- (Optional) Persist to disk with `UserDefaults` or Core Data (see **Persistence**)

### ⏱ Pomodoro Timer
- Standard 25‑minute focus session
- Short break (5 min) & long break (15 min) suggestions
- Haptics/alerts when sessions finish (optional)

---

## Tech Stack
- **Language:** Swift 5+
- **Framework:** SwiftUI
- **Minimum iOS:** 16.0 (adjust as needed)

---

## Project Structure
```
PersonalManagement/
├─ PersonalManagementApp.swift   # App entry point
├─ ContentView.swift             # Root content (e.g., TabView)
├─ HomeView.swift                # Landing / hub screen
├─ TodoView.swift                # To‑Do list UI
├─ PomodoroView.swift            # Pomodoro timer UI
├─ Item.swift                    # (Optional) shared models
├─ Preview Content/              # Assets for SwiftUI previews
│  └─ Assets.xcassets (preview)
├─ Assets/                       # App assets (app icons, colors)
├─ PersonalManagementTests/      # Unit tests
└─ PersonalManagementUITests/    # UI tests
```

---

## Getting Started

### Requirements
- Xcode 15+
- iOS 16+ Simulator or device

### Build & Run
1. Open `PersonalManagement.xcodeproj` (or `.xcworkspace` if using packages).
2. Select an iOS Simulator (e.g., iPhone 15) or your device.
3. **Run** ▶ (Cmd+R).

### Run Tests
- **Unit tests:** Cmd+U
- **UI tests:** Select UI test scheme or keep the default and run tests (Cmd+U).

---

## Usage

### To‑Do Tab
- Tap the **text field** to enter a task and press **➕** to add it.
- Tap the **circle** to toggle completion.
- **Swipe left** on a row to delete.

### Pomodoro Tab
- Tap **Start** to begin a 25‑minute focus session.
- When the timer ends, choose **Short Break** (5m) or **Long Break** (15m).
- Optionally enable haptics/notifications in code for alerts.

---

## Sample Models & ViewModels

> These are the minimal models used by the To‑Do module. Adjust names to match your codebase (e.g., keep them in `Item.swift` or separate files).

```swift
import Foundation

struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}

final class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = []

    func addItem(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        items.append(TodoItem(title: title))
    }

    func toggleCompletion(of item: TodoItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isCompleted.toggle()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
```

---

## Wire‑Up Example

### `ContentView.swift`
A simple TabView that exposes To‑Do and Pomodoro.

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodoView()
                .tabItem { Label("To‑Do", systemImage: "checklist") }

            PomodoroView()
                .tabItem { Label("Pomodoro", systemImage: "timer") }
        }
    }
}
```

### `TodoView.swift`

```swift
import SwiftUI

struct TodoView: View {
    @StateObject private var vm = TodoViewModel()
    @State private var newTask = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    TextField("Add a new task…", text: $newTask)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        vm.addItem(title: newTask)
                        newTask = ""
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                    .disabled(newTask.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(.plain)
                }
                .padding()

                List {
                    ForEach(vm.items) { item in
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .onTapGesture { vm.toggleCompletion(of: item) }
                            Text(item.title)
                                .strikethrough(item.isCompleted)
                                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
            }
            .navigationTitle("To‑Do")
        }
    }
}
```

> `PomodoroView.swift` can start as a placeholder (e.g., `Text("Pomodoro Timer")`) and be expanded with a countdown `Timer.publish` or `TimelineView`. See **Pomodoro Implementation Notes** below for a quick start.

---

## Pomodoro Implementation Notes (Quick Start)

```swift
import SwiftUI

final class PomodoroViewModel: ObservableObject {
    @Published var remaining: Int = 25 * 60
    @Published var isRunning = false
    private var timer: Timer?

    func start(seconds: Int = 25 * 60) {
        remaining = seconds
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            if self.remaining > 0 { self.remaining -= 1 } else { self.stop() }
        }
    }

    func stop() { isRunning = false; timer?.invalidate(); timer = nil }
}

struct PomodoroView: View {
    @StateObject private var vm = PomodoroViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(timeString(vm.remaining)).font(.system(size: 56, weight: .bold, design: .rounded))
            HStack {
                Button(vm.isRunning ? "Stop" : "Start") { vm.isRunning ? vm.stop() : vm.start() }
                    .buttonStyle(.borderedProminent)
                Menu("Preset") {
                    Button("Focus 25m") { vm.start(seconds: 25*60) }
                    Button("Short Break 5m") { vm.start(seconds: 5*60) }
                    Button("Long Break 15m") { vm.start(seconds: 15*60) }
                }
            }
        }
        .padding()
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
```
