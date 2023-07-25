// swift-tools-version: 5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codex",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
        .watchOS(.v3),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "Codex",
            targets: ["Codex"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Codex",
            dependencies: []
        ),
        .testTarget(
            name: "CodexTests",
            dependencies: ["Codex"]),
    ]
)
