// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "slox",
    products: [
        .executable(name: "slox", targets: ["slox"]),
        .library(name: "libslox", targets: ["libslox"])
    ],
    dependencies: [
        .package(url:  "https://github.com/Quick/Nimble.git", from: "13.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "slox",
            dependencies: ["libslox"]
        ),
        .target(
            name: "libslox",
            dependencies: []
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: ["libslox", "Nimble", "slox"]
        )
    ]
)
