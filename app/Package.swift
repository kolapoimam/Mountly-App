// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Mountly",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "MountlyCore", targets: ["MountlyCore"]),
        .executable(name: "Mountly", targets: ["Mountly"]),
        .executable(name: "MountlyHelperTool", targets: ["MountlyHelperTool"])
    ],
    targets: [
        .target(
            name: "MountlyCore",
            path: "Sources/MountlyCore"
        ),
        .executableTarget(
            name: "Mountly",
            dependencies: ["MountlyCore"],
            path: "Sources/Mountly",
            resources: [
                .copy("Resources/Fonts")
            ]
        ),
        .executableTarget(
            name: "MountlyHelperTool",
            dependencies: ["MountlyCore"],
            path: "Sources/MountlyHelperTool"
        ),
        .testTarget(
            name: "MountlyCoreTests",
            dependencies: ["MountlyCore"],
            path: "Tests/MountlyCoreTests"
        ),
        .testTarget(
            name: "MountlyIntegrationTests",
            dependencies: ["MountlyCore"],
            path: "Tests/MountlyIntegrationTests"
        )
    ]
)
