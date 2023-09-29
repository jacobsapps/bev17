// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Database",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Database",
            targets: ["Database"]),
        .library(
            name: "DatabaseMocks",
            targets: ["DatabaseMocks"]),
    ],
    dependencies: [
        .package(url: "./Domain", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Database",
            dependencies: ["Domain"]),
        .target(
            name: "DatabaseMocks",
            dependencies: [
                "Domain",
                .product(name: "TestUtilities", package: "Domain")
            ]),
        .testTarget(
            name: "DatabaseTests",
            dependencies: [
                "Database",
                "DatabaseMocks",
                .product(name: "TestUtilities", package: "Domain")
            ]),
    ]
)
