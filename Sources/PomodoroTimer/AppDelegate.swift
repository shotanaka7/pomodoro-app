import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let timerManager = TimerManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.requestPermission()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro Timer")
            button.action = #selector(togglePopover)
            button.target = self
            updateStatusBarTitle()
        }

        let contentView = StatusBarView(timerManager: timerManager)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)

        timerManager.onTick = { [weak self] in
            self?.updateStatusBarTitle()
        }
    }

    private func updateStatusBarTitle() {
        guard let button = statusItem.button else { return }

        if timerManager.isRunning || timerManager.isPaused {
            let minutes = timerManager.remainingSeconds / 60
            let seconds = timerManager.remainingSeconds % 60
            let emoji: String
            switch timerManager.currentPhase {
            case .work: emoji = "🍅"
            case .lunchBreak: emoji = "🍱"
            default: emoji = "☕"
            }
            button.title = " \(emoji) \(String(format: "%02d:%02d", minutes, seconds))"
        } else {
            button.title = ""
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
