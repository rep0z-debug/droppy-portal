import Foundation

enum Uptime {
    static func short(since start: Date, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(start)))
        if seconds < 60 { return "\(seconds)s" }

        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m" }

        let hours = minutes / 60
        if hours < 24 { return "\(hours)h \(minutes % 60)m" }

        let days = hours / 24
        return "\(days)d \(hours % 24)h"
    }
}
