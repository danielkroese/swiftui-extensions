// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftUIExtensions",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SwiftUIExtensions",
            targets: ["SwiftUIExtensions"]),
    ],
    targets: [
        .target(
            name: "SwiftUIExtensions"),
        .testTarget(
            name: "SwiftUIExtensionsTests",
            dependencies: ["SwiftUIExtensions"]),
    ]
)
