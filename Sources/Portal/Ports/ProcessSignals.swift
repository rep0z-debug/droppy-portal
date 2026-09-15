import Darwin
import Foundation

enum ProcessSignals {
    enum Outcome: Sendable {
        case delivered
        case gone
        case refused
    }

    static func stop(_ processID: pid_t, startedAt: Date, force: Bool) -> Outcome {
        guard processID > 1, processID != getpid() else { return .refused }
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        guard proc_pidinfo(processID, PROC_PIDTBSDINFO, 0, &info, size) == size else { return .gone }
        guard info.pbi_uid == getuid() else { return .refused }
        guard TimeInterval(info.pbi_start_tvsec) == startedAt.timeIntervalSince1970 else { return .gone }
        guard kill(processID, force ? SIGKILL : SIGTERM) == 0 else {
            return errno == EPERM ? .refused : .gone
        }
        return .delivered
    }
}
