// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]),
        .library(
            name: "NetworkingMocks",
            targets: ["NetworkingMocks"]),
    ],
    dependencies: [
        .package(url: "./Domain", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: ["Domain"]),
        .target(
            name: "NetworkingMocks",
            dependencies: [
                "Domain",
                .product(name: "TestUtilities", package: "Domain")
            ]),
        .testTarget(
            name: "NetworkingTests",
            dependencies: [
                "Networking",
                "NetworkingMocks",
                .product(name: "TestUtilities", package: "Domain")
            ]),
    ]
)
