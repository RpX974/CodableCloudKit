// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CodableCloudKit",
    products: [
        .library(
            name: "CodableCloudKit",
            targets: ["CodableCloudKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CodableCloudKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CodableCloudKitTests",
            dependencies: ["CodableCloudKit"],
            path: "Tests"
        ),
    ]
)
