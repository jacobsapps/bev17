// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]),
        .library(
            name: "TestUtilities",
            targets: ["TestUtilities"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Domain",
            dependencies: []),
        .target(
            name: "TestUtilities",
            dependencies: ["Domain"]),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]),
    ]
)
