// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PomodoroTimer",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "PomodoroTimer",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate",
                              "-Xlinker", "__TEXT",
                              "-Xlinker", "__info_plist",
                              "-Xlinker", "Resources/Info.plist"])
            ]
        ),
    ]
)
