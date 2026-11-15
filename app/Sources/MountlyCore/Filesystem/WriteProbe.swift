import Foundation

/// The one non-destructive write/read verification routine every backend
/// uses before ever claiming "Write access verified": create a
/// uniquely-named hidden file → confirm it exists → read it back and
/// compare bytes → delete it → confirm it's gone. Shared so every backend
/// (native or third-party) proves writability the same, real way — never
/// just a successful exit code.
public enum WriteProbe {
    public static func verifyRead(mountPoint: URL) -> Bool {
        (try? FileManager.default.contentsOfDirectory(atPath: mountPoint.path)) != nil
    }

    public static func verifyWrite(mountPoint: URL) -> Bool {
        let probeName = ".mountly_write_test_\(UUID().uuidString.prefix(8))"
        let probeURL = mountPoint.appendingPathComponent(probeName)
        let probeContent = "mountly-write-probe".data(using: .utf8)!

        do {
            try probeContent.write(to: probeURL, options: .atomic)
            guard FileManager.default.fileExists(atPath: probeURL.path) else { return false }
            let readBack = try Data(contentsOf: probeURL)
            guard readBack == probeContent else { return false }
            try FileManager.default.removeItem(at: probeURL)
            return !FileManager.default.fileExists(atPath: probeURL.path)
        } catch {
            try? FileManager.default.removeItem(at: probeURL)
            return false
        }
    }
}
