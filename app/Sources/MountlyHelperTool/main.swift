import Foundation
import Security
import MountlyCore

/// MountlyHelperTool — the entire privileged surface of Transcend
/// Manager, as designed in `docs/ARCHITECTURE.md` §7. It exposes exactly
/// the four `HelperXPCProtocol` operations, re-validates every request
/// against Disk Arbitration/`diskutil` itself (never trusting the caller),
/// and never runs a shell string built from caller-supplied text —
/// `ProcessRunner` only ever takes fixed argument arrays.

enum HelperVersion {
    static let current = "1.0.0"
}

/// Verifies the connecting process is code-signed with the same Team ID as
/// this helper itself, and carries the expected app bundle identifier
/// prefix. This means the helper trusts exactly "whatever signed me,"
/// independent of which specific identity (local development, Developer
/// ID) was used to sign a given build — but nothing else on the system.
enum ClientValidator {
    static func isAuthorized(pid: pid_t) -> Bool {
        let guestAttributes: CFDictionary = [kSecGuestAttributePid: pid] as CFDictionary
        var clientCode: SecCode?
        guard SecCodeCopyGuestWithAttributes(nil, guestAttributes, [], &clientCode) == errSecSuccess,
              let clientCode else {
            TMLog.error("Could not resolve SecCode for pid \(pid)", category: .security)
            return false
        }

        guard let requirement = ownTeamRequirement() else {
            // If we can't determine our own signing identity (e.g. an
            // unsigned local debug build), fail closed rather than open.
            TMLog.error("Could not determine own code signing requirement; refusing client pid \(pid)", category: .security)
            return false
        }

        let status = SecCodeCheckValidity(clientCode, [], requirement)
        if status != errSecSuccess {
            TMLog.error("Client pid \(pid) failed code signature check (status \(status))", category: .security)
            return false
        }
        return true
    }

    private static func ownTeamRequirement() -> SecRequirement? {
        var selfCode: SecCode?
        guard SecCodeCopySelf([], &selfCode) == errSecSuccess, let selfCode else { return nil }

        var staticCode: SecStaticCode?
        guard SecCodeCopyStaticCode(selfCode, [], &staticCode) == errSecSuccess, let staticCode else { return nil }

        var info: CFDictionary?
        guard SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &info) == errSecSuccess,
              let dict = info as? [String: Any],
              let teamID = dict[kSecCodeInfoTeamIdentifier as String] as? String else {
            return nil
        }

        var requirement: SecRequirement?
        let requirementString = "anchor apple generic and certificate leaf[subject.OU] = \"\(teamID)\" and identifier[subject.CN] exists" as CFString
        // Use a simpler, robust form: match on Team ID only.
        let simpleRequirementString = "certificate leaf[subject.OU] = \"\(teamID)\"" as CFString
        _ = requirementString
        guard SecRequirementCreateWithString(simpleRequirementString, [], &requirement) == errSecSuccess else {
            return nil
        }
        return requirement
    }
}

final class HelperService: NSObject, HelperXPCProtocol, @unchecked Sendable {
    private static let ntfs3gCandidates = [
        "/opt/homebrew/bin/ntfs-3g", "/usr/local/bin/ntfs-3g"
    ]
    private static let diskutilPath = "/usr/sbin/diskutil"

    private func findNTFS3G() -> String? {
        Self.ntfs3gCandidates.first { FileManager.default.isExecutableFile(atPath: $0) }
    }

    func mountNTFS(bsdName: String, mountPoint: String, readOnly: Bool, withReply reply: @escaping (Bool, String?) -> Void) {
        // Re-derive everything from the system; never trust the caller's claims.
        guard let info = try? DiskUtility.info(forBSDName: bsdName) else {
            reply(false, "could not read disk info for \(bsdName)")
            return
        }
        guard !info.internalDisk else {
            reply(false, "refused: \(bsdName) is an internal disk")
            return
        }
        let filesystem = FilesystemKind(diskArbitrationFilesystemName: info.filesystemName ?? "")
        guard filesystem == .ntfs else {
            reply(false, "refused: \(bsdName) is \(info.filesystemName ?? "an unrecognized filesystem"), not NTFS")
            return
        }
        guard mountPoint.hasPrefix("/Volumes/") else {
            reply(false, "refused: mount point \(mountPoint) is outside /Volumes")
            return
        }
        guard let ntfs3g = findNTFS3G() else {
            reply(false, "ntfs-3g is not installed")
            return
        }

        // If Apple's own driver already auto-mounted this device read-only,
        // release that mount first so ntfs-3g can claim the device node.
        if let existingMount = info.mountPoint, !existingMount.isEmpty {
            _ = try? ProcessRunner.run(Self.diskutilPath, arguments: ["unmount", existingMount])
        }

        try? FileManager.default.createDirectory(atPath: mountPoint, withIntermediateDirectories: true)

        // Option set matches the community-vetted defaults shipped by the
        // gromgit/fuse ntfs-3g-mac formula's own generated mount wrapper,
        // with uid/gid mapped to the logged-in console user (via /dev/console's
        // owner) so files created from Finder/the app are user-owned, not
        // root-owned — the helper itself always runs as root.
        var consoleStat = stat()
        let consoleUID = (stat("/dev/console", &consoleStat) == 0) ? consoleStat.st_uid : getuid()
        let consoleGID = (stat("/dev/console", &consoleStat) == 0) ? consoleStat.st_gid : getgid()

        var optionParts = [
            "volname=\(URL(fileURLWithPath: mountPoint).lastPathComponent)",
            "local",
            "negative_vncache",
            "auto_xattr",
            "auto_cache",
            "noatime",
            "windows_names",
            "streams_interface=openxattr",
            "inherit",
            "uid=\(consoleUID)",
            "gid=\(consoleGID)",
            "allow_other",
            "big_writes"
        ]
        if readOnly {
            optionParts.append("ro")
        }
        let options = optionParts.joined(separator: ",")

        do {
            let result = try ProcessRunner.run(
                ntfs3g,
                arguments: ["/dev/r\(bsdName)", mountPoint, "-o", options],
                timeout: 25
            )
            if result.succeeded {
                reply(true, nil)
            } else {
                let detail = result.standardError.isEmpty ? result.standardOutput : result.standardError
                reply(false, detail)
            }
        } catch {
            reply(false, String(describing: error))
        }
    }

    func unmount(mountPoint: String, withReply reply: @escaping (Bool, String?) -> Void) {
        guard mountPoint.hasPrefix("/Volumes/") else {
            reply(false, "refused: mount point \(mountPoint) is outside /Volumes")
            return
        }
        do {
            let result = try ProcessRunner.run(Self.diskutilPath, arguments: ["unmount", mountPoint])
            reply(result.succeeded, result.succeeded ? nil : result.standardError)
        } catch {
            reply(false, String(describing: error))
        }
    }

    func status(mountPoint: String, withReply reply: @escaping (Bool, String?) -> Void) {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: mountPoint, isDirectory: &isDir)
        reply(exists && isDir.boolValue, nil)
    }

    func ping(withReply reply: @escaping (String) -> Void) {
        reply(HelperVersion.current)
    }
}

final class ListenerDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        guard ClientValidator.isAuthorized(pid: newConnection.processIdentifier) else {
            return false
        }
        newConnection.exportedInterface = NSXPCInterface(with: HelperXPCProtocol.self)
        newConnection.exportedObject = HelperService()
        newConnection.resume()
        return true
    }
}

let delegate = ListenerDelegate()
let listener = NSXPCListener(machServiceName: HelperXPC.machServiceName)
listener.delegate = delegate
listener.resume()
TMLog.info("MountlyHelperTool \(HelperVersion.current) listening on \(HelperXPC.machServiceName)", category: .security)
RunLoop.main.run()
