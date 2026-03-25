import Foundation

struct WorkLogEntry: Codable {
    let phase: TimerPhase
    let startDate: Date
    let endDate: Date
    let durationMinutes: Int
    let completedSessions: Int
}

struct DailyLog: Codable {
    let date: String
    var entries: [WorkLogEntry]
    var totalWorkMinutes: Int
    var totalSessions: Int
}

final class WorkLogManager: @unchecked Sendable {
    static let shared = WorkLogManager()

    private let logDirectory: URL
    private let dateFormatter: DateFormatter
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        logDirectory = appSupport.appendingPathComponent("PomodoroTimer/logs", isDirectory: true)

        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func logSession(phase: TimerPhase, startDate: Date, endDate: Date, completedSessions: Int) {
        let durationMinutes = Int(endDate.timeIntervalSince(startDate) / 60)
        let entry = WorkLogEntry(
            phase: phase,
            startDate: startDate,
            endDate: endDate,
            durationMinutes: durationMinutes,
            completedSessions: completedSessions
        )

        let dateString = dateFormatter.string(from: Date())
        let logFile = logDirectory.appendingPathComponent("\(dateString).json")

        var dailyLog: DailyLog
        if let data = try? Data(contentsOf: logFile),
           let existing = try? decoder.decode(DailyLog.self, from: data) {
            dailyLog = existing
        } else {
            dailyLog = DailyLog(date: dateString, entries: [], totalWorkMinutes: 0, totalSessions: 0)
        }

        dailyLog.entries.append(entry)
        if phase == .work {
            dailyLog.totalWorkMinutes += durationMinutes
            dailyLog.totalSessions = completedSessions
        }

        if let data = try? encoder.encode(dailyLog) {
            try? data.write(to: logFile, options: .atomic)
        }
    }

    func todayLog() -> DailyLog? {
        let dateString = dateFormatter.string(from: Date())
        let logFile = logDirectory.appendingPathComponent("\(dateString).json")

        guard let data = try? Data(contentsOf: logFile),
              let log = try? decoder.decode(DailyLog.self, from: data) else {
            return nil
        }
        return log
    }
}
