import SwiftUI

struct StatusBarView: View {
    @Bindable var timerManager: TimerManager

    var body: some View {
        VStack(spacing: 16) {
            headerView
            timerDisplay
            controlButtons
            lunchBreakSection
            statsView
            Divider()
            quitButton
        }
        .padding(20)
        .frame(width: 300)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 4) {
            Text("Pomodoro Timer")
                .font(.headline)
            Text(phaseLabel)
                .font(.subheadline)
                .foregroundStyle(phaseColor)
        }
    }

    private var phaseLabel: String {
        if !timerManager.isRunning && !timerManager.isPaused {
            return "準備完了"
        }
        return timerManager.currentPhase.rawValue
    }

    private var phaseColor: Color {
        switch timerManager.currentPhase {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        case .lunchBreak: return .orange
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(phaseColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerManager.progress)

            Text(timerManager.formattedTime)
                .font(.system(size: 44, weight: .light, design: .monospaced))
        }
        .frame(width: 160, height: 160)
        .padding(.vertical, 8)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 12) {
            if timerManager.isRunning {
                controlButton("pause.fill", label: "一時停止") {
                    timerManager.pause()
                }
            } else {
                controlButton("play.fill", label: timerManager.isPaused ? "再開" : "開始") {
                    timerManager.start()
                }
            }

            controlButton("forward.fill", label: "スキップ") {
                timerManager.skip()
            }
            .disabled(!timerManager.isRunning && !timerManager.isPaused)

            controlButton("arrow.counterclockwise", label: "リセット") {
                timerManager.reset()
            }
        }
    }

    private func controlButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.title2)
                Text(label)
                    .font(.caption2)
            }
            .frame(width: 64, height: 48)
        }
        .buttonStyle(.bordered)
    }

    // MARK: - Lunch Break

    private var lunchBreakSection: some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                Text("🍱 お昼休憩")
                    .font(.caption)
                Spacer()
                Stepper(
                    "\(timerManager.lunchBreakDuration / 60)分",
                    value: $timerManager.lunchBreakDuration,
                    in: (15 * 60)...(120 * 60),
                    step: 15 * 60
                )
                .font(.caption)
            }
            Button(action: { timerManager.startLunchBreak() }) {
                Label("お昼休憩を開始", systemImage: "fork.knife")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .disabled(timerManager.currentPhase == .lunchBreak && timerManager.isRunning)
        }
    }

    // MARK: - Stats

    private var statsView: some View {
        VStack(spacing: 6) {
            HStack {
                Text("今日の完了セッション")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(timerManager.totalCompletedToday) 🍅")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            if let log = WorkLogManager.shared.todayLog() {
                HStack {
                    Text("合計作業時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(log.totalWorkMinutes) 分")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Quit

    private var quitButton: some View {
        Button("終了") {
            NSApplication.shared.terminate(nil)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.secondary)
        .font(.caption)
    }
}
