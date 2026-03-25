import Foundation

enum TimerPhase: String, Codable {
    case work = "作業"
    case shortBreak = "休憩"
    case longBreak = "長休憩"
}

@MainActor
@Observable
final class TimerManager {
    // Settings
    var workDuration: Int = 25 * 60
    var shortBreakDuration: Int = 5 * 60
    var longBreakDuration: Int = 15 * 60
    var longBreakInterval: Int = 4

    // State
    private(set) var currentPhase: TimerPhase = .work
    private(set) var remainingSeconds: Int = 25 * 60
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var completedWorkSessions: Int = 0
    private(set) var totalCompletedToday: Int = 0

    var onTick: (() -> Void)?

    private var timer: Timer?
    private var currentSessionStartDate: Date?

    var progress: Double {
        let total = totalSecondsForCurrentPhase
        guard total > 0 else { return 0 }
        return Double(total - remainingSeconds) / Double(total)
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var totalSecondsForCurrentPhase: Int {
        switch currentPhase {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    func start() {
        if !isPaused {
            remainingSeconds = totalSecondsForCurrentPhase
            currentSessionStartDate = Date()
        }
        isRunning = true
        isPaused = false
        startTimer()
    }

    func pause() {
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        currentPhase = .work
        remainingSeconds = workDuration
        completedWorkSessions = 0
        currentSessionStartDate = nil
        onTick?()
    }

    func skip() {
        timer?.invalidate()
        timer = nil
        advancePhase()
        start()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        onTick?()

        if remainingSeconds <= 0 {
            timerCompleted()
        }
    }

    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false

        if currentPhase == .work {
            completedWorkSessions += 1
            totalCompletedToday += 1

            WorkLogManager.shared.logSession(
                phase: currentPhase,
                startDate: currentSessionStartDate ?? Date(),
                endDate: Date(),
                completedSessions: totalCompletedToday
            )
        }

        let completedPhase = currentPhase
        NotificationManager.shared.sendNotification(for: completedPhase)

        advancePhase()
        remainingSeconds = totalSecondsForCurrentPhase
        onTick?()
    }

    private func advancePhase() {
        switch currentPhase {
        case .work:
            if completedWorkSessions % longBreakInterval == 0 {
                currentPhase = .longBreak
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
        }
        currentSessionStartDate = nil
    }
}
