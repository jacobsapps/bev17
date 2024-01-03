// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Repository",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Repository",
            targets: ["Repository"]),
        .library(
            name: "RepositoryMocks",
            targets: ["RepositoryMocks"]),
    ],
    dependencies: [
        .package(url: "./Networking", from: "1.0.0"),
        .package(url: "./Domain", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Repository",
            dependencies: ["Networking", "Domain"]),
        .target(
            name: "RepositoryMocks",
            dependencies: [
                "Domain",
                "Repository",
                .product(name: "TestUtilities", package: "Domain")
            ]),
        .testTarget(
            name: "RepositoryTests",
            dependencies: [
                "Repository",
                .product(name: "NetworkingMocks", package: "Networking")
            ]),
    ]
)
