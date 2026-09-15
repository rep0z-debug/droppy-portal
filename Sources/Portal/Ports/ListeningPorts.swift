import Darwin
import Foundation

enum ListeningPorts {
    static func current() -> [ListeningSocket] {
        let owner = getuid()
        var sockets: [ListeningSocket] = []
        for processID in liveProcessIdentifiers() {
            guard let process = describe(processID), process.owner == owner else { continue }
            let bindings = listeningBindings(of: processID)
            guard !bindings.isEmpty else { continue }
            let path = executablePath(of: processID)
            for binding in bindings {
                sockets.append(
                    ListeningSocket(
                        processID: processID,
                        port: binding.port,
                        reach: binding.reach,
                        processName: process.name,
                        executablePath: path,
                        startedAt: process.startedAt
                    )
                )
            }
        }
        return sockets
    }
}

private extension ListeningPorts {
    struct ProcessDescription {
        let owner: uid_t
        let name: String
        let startedAt: Date
    }

    struct Binding {
        let port: UInt16
        let reach: PortReach
    }

    static func liveProcessIdentifiers() -> [pid_t] {
        let probed = proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0)
        guard probed > 0 else { return [] }
        let capacity = Int(probed) / MemoryLayout<pid_t>.size + 64
        var identifiers = [pid_t](repeating: 0, count: capacity)
        let written = identifiers.withUnsafeMutableBufferPointer { buffer in
            proc_listpids(
                UInt32(PROC_ALL_PIDS),
                0,
                buffer.baseAddress,
                Int32(buffer.count * MemoryLayout<pid_t>.size)
            )
        }
        guard written > 0 else { return [] }
        let count = min(capacity, Int(written) / MemoryLayout<pid_t>.size)
        return identifiers[0..<count].filter { $0 > 0 }
    }

    static func describe(_ processID: pid_t) -> ProcessDescription? {
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        guard proc_pidinfo(processID, PROC_PIDTBSDINFO, 0, &info, size) == size else { return nil }
        let name = withUnsafeBytes(of: info.pbi_name) { text(in: $0) }
        let command = withUnsafeBytes(of: info.pbi_comm) { text(in: $0) }
        return ProcessDescription(
            owner: info.pbi_uid,
            name: name.isEmpty ? command : name,
            startedAt: Date(timeIntervalSince1970: TimeInterval(info.pbi_start_tvsec))
        )
    }

    static func listeningBindings(of processID: pid_t) -> [Binding] {
        let probed = proc_pidinfo(processID, PROC_PIDLISTFDS, 0, nil, 0)
        guard probed > 0 else { return [] }
        let capacity = Int(probed) / MemoryLayout<proc_fdinfo>.size + 32
        var descriptors = [proc_fdinfo](repeating: proc_fdinfo(), count: capacity)
        let written = descriptors.withUnsafeMutableBufferPointer { buffer in
            proc_pidinfo(
                processID,
                PROC_PIDLISTFDS,
                0,
                buffer.baseAddress,
                Int32(buffer.count * MemoryLayout<proc_fdinfo>.size)
            )
        }
        guard written > 0 else { return [] }
        let count = min(capacity, Int(written) / MemoryLayout<proc_fdinfo>.size)
        var bindings: [Binding] = []
        for index in 0..<count where descriptors[index].proc_fdtype == UInt32(PROX_FDTYPE_SOCKET) {
            guard let binding = binding(of: processID, descriptor: descriptors[index].proc_fd) else { continue }
            bindings.append(binding)
        }
        return bindings
    }

    static func binding(of processID: pid_t, descriptor: Int32) -> Binding? {
        var info = socket_fdinfo()
        let size = Int32(MemoryLayout<socket_fdinfo>.size)
        guard proc_pidfdinfo(processID, descriptor, PROC_PIDFDSOCKETINFO, &info, size) == size else { return nil }
        guard info.psi.soi_kind == SOCKINFO_TCP else { return nil }
        let tcp = info.psi.soi_proto.pri_tcp
        guard tcp.tcpsi_state == TSI_S_LISTEN else { return nil }
        let port = UInt16(bigEndian: UInt16(truncatingIfNeeded: tcp.tcpsi_ini.insi_lport))
        guard port > 0 else { return nil }
        return Binding(port: port, reach: reach(of: tcp.tcpsi_ini))
    }

    static func reach(of socket: in_sockinfo) -> PortReach {
        guard socket.insi_vflag & UInt8(INI_IPV4) != 0 else { return sixReach(of: socket) }
        let address = socket.insi_laddr.ina_46.i46a_addr4.s_addr
        if IPv4Address.isUnspecified(networkOrder: address) { return .allInterfaces }
        if IPv4Address.isLoopback(networkOrder: address) { return .loopback }
        return .interface(IPv4Address.text(networkOrder: address))
    }

    static func sixReach(of socket: in_sockinfo) -> PortReach {
        let bytes = withUnsafeBytes(of: socket.insi_laddr.ina_6) { Array($0) }
        guard bytes.count == 16 else { return .allInterfaces }
        if bytes.allSatisfy({ $0 == 0 }) { return .allInterfaces }
        if bytes.dropLast().allSatisfy({ $0 == 0 }), bytes[15] == 1 { return .loopback }
        if bytes.prefix(10).allSatisfy({ $0 == 0 }), bytes[10] == 0xff, bytes[11] == 0xff {
            let mapped = bytes[12...].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
            if IPv4Address.isUnspecified(networkOrder: mapped) { return .allInterfaces }
            if IPv4Address.isLoopback(networkOrder: mapped) { return .loopback }
            return .interface(IPv4Address.text(networkOrder: mapped))
        }
        return .allInterfaces
    }

    static func executablePath(of processID: pid_t) -> String {
        var buffer = [UInt8](repeating: 0, count: Int(PATH_MAX) * 4)
        let written = buffer.withUnsafeMutableBufferPointer { storage in
            proc_pidpath(processID, storage.baseAddress, UInt32(storage.count))
        }
        guard written > 0 else { return "" }
        return String(decoding: buffer[0..<Int(written)], as: UTF8.self)
    }

    static func text(in raw: UnsafeRawBufferPointer) -> String {
        String(decoding: raw.prefix(while: { $0 != 0 }), as: UTF8.self)
    }
}
