// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Manfred",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Manfred",
            targets: ["Manfred"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Manfred",
            dependencies: []),
        .testTarget(
            name: "ManfredTests",
            dependencies: ["Manfred"],
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)
