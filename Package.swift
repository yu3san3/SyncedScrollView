// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SyncedScrollView",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SyncedScrollView",
            targets: ["SyncedScrollView"]
        ),
    ],
    targets: [
        .target(
            name: "SyncedScrollView"
        ),
    ]
)
