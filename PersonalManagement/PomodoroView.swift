import SwiftUI

struct PomodoroView: View {
    enum TimerState {
        case work, shortBreak, longBreak, completed
    }
    
    @State private var timerState: TimerState = .work
    @State private var timeRemaining: Int = 25 * 60
    @State private var isActive = false
    @State private var completedCycles = 0
    @State private var targetCycles = 4
    @State private var currentTask = ""
    @State private var showTaskInput = true
    @State private var showCelebration = false
    @State private var completedTasks: [String] = []
    @State private var showCompletionOptions = false
    @State private var newTaskAfterCompletion = ""
    @State private var showConfigOnNewTask = false
    
    
    // Editable timer settings with text input
    @State private var workMinutes: String = "25"
    @State private var shortBreakMinutes: String = "5"
    @State private var longBreakMinutes: String = "30"
    
    private var currentColor: Color {
        switch timerState {
        case .work: return .blue
        case .shortBreak: return .green
        case .longBreak: return .purple
        case .completed: return Color(red: 0.96, green: 0.87, blue: 0.7) // Light brown
        }
    }
    
    private var progress: Double {
        let duration: Int
        switch timerState {
        case .work: duration = (Int(workMinutes) ?? 25) * 60
        case .shortBreak: duration = (Int(shortBreakMinutes) ?? 5) * 60
        case .longBreak: duration = (Int(longBreakMinutes) ?? 30) * 60
        case .completed: duration = 1
        }
        return 1 - (Double(timeRemaining) / Double(duration))
    }
    
    private var cycleProgress: Double {
        Double(completedCycles) / Double(targetCycles)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            currentColor.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            // Celebration animation
            if showCelebration {
                ConfettiView()
                    .transition(.opacity)
            }
            
            VStack {
                Spacer()
                
                // Main content container
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        if !currentTask.isEmpty {
                            Text("Current Task")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(currentTask)
                                .font(.title2)
                                .bold()
                                .foregroundColor(currentColor)
                                .transition(.scale)
                        }
                        
                        // Progress bar for cycles
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 20)
                                .foregroundColor(currentColor.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: CGFloat(cycleProgress) * UIScreen.main.bounds.width * 0.8, height: 20)
                                .foregroundColor(currentColor)
                                .animation(.spring(), value: cycleProgress)
                            
                            HStack {
                                Text("\(completedCycles)/\(targetCycles)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    
                    // Timer Display
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(currentColor)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(style: StrokeStyle(
                                lineWidth: 20,
                                lineCap: .round
                            ))
                            .foregroundColor(currentColor)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: progress)
                        
                        VStack {
                            Text(formattedTime(timeRemaining))
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(currentColor)
                            
                            Text(timerState == .work ? "FOCUS" :
                                 timerState == .completed ? "COMPLETED" : "BREAK")
                                .font(.title3)
                                .bold()
                                .foregroundColor(currentColor.opacity(0.7))
                        }
                    }
                    .frame(width: 250, height: 250)
                    .padding(.vertical, 20)
                    
                    // Controls - Only show if not completed
                    if timerState != .completed {
                        HStack(spacing: 30) {
                            Button(action: toggleTimer) {
                                Image(systemName: isActive ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(currentColor)
                            }
                            
                            Button(action: resetTimer) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(currentColor)
                            }
                        }
                    }
                    
                    // Update the Completed Tasks section in the body:
                    if !completedTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Completed Tasks (\(completedTasks.count))")
                                .font(.headline)
                                .foregroundColor(currentColor.opacity(0.7))
                            
                            ScrollView {
                                ForEach(completedTasks.reversed(), id: \.self) { task in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(task)
                                            .strikethrough()
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                    .transition(.slide)
                                }
                            }
                            .frame(maxHeight: 150)
                            
                            // Completion options (shown only when in completed state)
                            if timerState == .completed {
                                VStack(spacing: 15) {
                                    TextField("Next task to work on", text: $newTaskAfterCompletion)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    HStack(spacing: 20) {
                                        Button(action: startNewTask) {
                                            Text("Add Task")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(GrowingButton())
                                        .disabled(newTaskAfterCompletion.isEmpty)
                                        
                                        Button(action: clearAllTasks) {
                                            Text("Clear History")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(GrowingButton(backgroundColor: .gray))
                                    }
                                }
                                .padding(.top)
                                .transition(.scale)
                            }
                        }
                        .padding(.top)
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Task Input Overlay
            if showTaskInput || showConfigOnNewTask {
                TaskInputView(
                    currentTask: $currentTask,
                    targetCycles: $targetCycles,
                    workMinutes: $workMinutes,
                    shortBreakMinutes: $shortBreakMinutes,
                    longBreakMinutes: $longBreakMinutes,
                    isPresented: $showTaskInput,
                    isNewTaskFlow: showConfigOnNewTask
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .onChange(of: showTaskInput) { newValue in
                    if !newValue {
                        showConfigOnNewTask = false
                    }
                }
            }

        }
        .onReceive(timer) { _ in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completePhase()
            }
        }
        .onChange(of: completedCycles) { _ in
            if completedCycles >= targetCycles {
                celebrateCompletion()
                timerState = .completed
                isActive = false
            }
        }
        .onChange(of: showTaskInput) { _ in
            resetTimer()
        }
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        isActive.toggle()
    }
    
    private func completePhase() {
        if timerState == .work {
            completedCycles += 1
            if !currentTask.isEmpty && completedCycles == targetCycles {
                // Only add to completed tasks if it's not empty and not already in the list
                if !completedTasks.contains(currentTask) {
                    completedTasks.append(currentTask)
                }
                currentTask = ""
            }
            
            if completedCycles < targetCycles {
                timerState = (completedCycles % 4 == 0) ? .longBreak : .shortBreak
            }
        } else {
            timerState = .work
        }
        resetTimer()
        isActive = true // Auto-start next phase
    }
    
    private func resetTimer() {
        switch timerState {
        case .work:
            timeRemaining = (Int(workMinutes) ?? 25) * 60
        case .shortBreak:
            timeRemaining = (Int(shortBreakMinutes) ?? 5) * 60
        case .longBreak:
            timeRemaining = (Int(longBreakMinutes) ?? 30) * 60
        case .completed:
            break
        }
    }
    
    private func celebrateCompletion() {
        withAnimation {
            showCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCelebration = false
                showCompletionOptions = true
            }
        }
    }
    
    
    // Modify the startNewTask function to not clear completed tasks:
    private func startNewTask() {
        withAnimation {
            if newTaskAfterCompletion.isEmpty {
                currentTask = ""
            } else {
                currentTask = newTaskAfterCompletion
            }
            newTaskAfterCompletion = ""
            completedCycles = 0
            timerState = .work
            resetTimer()
            isActive = false
            
            // Show configuration options
            showConfigOnNewTask = true
            showTaskInput = true
        }
    }
    
    

    private func clearAllTasks() {
        withAnimation {
            currentTask = ""
            newTaskAfterCompletion = ""
            completedTasks.removeAll() // This clears the history
            completedCycles = 0
            timerState = .work
            resetTimer()
            isActive = false
            showTaskInput = true
        }
    }
    
    
}

// MARK: - Supporting Views

// Update the TaskInputView struct:
struct TaskInputView: View {
    @Binding var currentTask: String
    @Binding var targetCycles: Int
    @Binding var workMinutes: String
    @Binding var shortBreakMinutes: String
    @Binding var longBreakMinutes: String
    @Binding var isPresented: Bool
    var isNewTaskFlow: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isNewTaskFlow ? "Configure New Session" : "Set Your Focus Session")
                .font(.title)
                .bold()
            
            if !isNewTaskFlow {
                TextField("What are you working on?", text: $currentTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            VStack(spacing: 15) {
                // Work minutes with text input
                HStack {
                    Text("Focus Minutes:")
                    Spacer()
                    TextField("25", text: $workMinutes)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Stepper("", value: Binding(
                        get: { Int(workMinutes) ?? 25 },
                        set: { workMinutes = String($0) }
                    ), in: 1...60)
                }
                
                // Short break with text input
                HStack {
                    Text("Short Break:")
                    Spacer()
                    TextField("5", text: $shortBreakMinutes)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Stepper("", value: Binding(
                        get: { Int(shortBreakMinutes) ?? 5 },
                        set: { shortBreakMinutes = String($0) }
                    ), in: 1...15)
                }
                
                // Long break with text input
                HStack {
                    Text("Long Break:")
                    Spacer()
                    TextField("30", text: $longBreakMinutes)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Stepper("", value: Binding(
                        get: { Int(longBreakMinutes) ?? 30 },
                        set: { longBreakMinutes = String($0) }
                    ), in: 5...30)
                }
                
                // Target cycles
                Stepper("Target Cycles: \(targetCycles)", value: $targetCycles, in: 1...10)
            }
            .padding(.horizontal)
            
            Button(isNewTaskFlow ? "Start New Session" : "Start Focusing") {
                withAnimation {
                    isPresented = false
                }
            }
            .buttonStyle(GrowingButton())
            .disabled(!isNewTaskFlow && currentTask.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

// Rest of the code remains the same...

struct GrowingButton: ButtonStyle {
    var backgroundColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}



struct ConfettiView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.xOffset, y: particle.yOffset)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            // Create multiple particle types
            for _ in 0..<100 {
                particles.append(Particle(type: .circle))
                particles.append(Particle(type: .rectangle))
                particles.append(Particle(type: .triangle))
            }
        }
    }
}

enum ParticleType {
    case circle, rectangle, triangle
}

struct Particle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let opacity: Double
    let rotation: Angle
    let type: ParticleType
    
    init(type: ParticleType) {
        self.type = type
        color = [Color.red, .blue, .green, .yellow, .purple, .orange].randomElement()!
        size = CGFloat.random(in: 5...15)
        xOffset = CGFloat.random(in: -200...200)
        yOffset = CGFloat.random(in: -400...0) // Start above screen
        opacity = Double.random(in: 0.7...1.0)
        rotation = .degrees(Double.random(in: 0...360))
    }
}
