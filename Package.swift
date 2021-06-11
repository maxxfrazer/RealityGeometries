// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealityGeometries",
    platforms: [.iOS("15.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RealityGeometries",
            targets: ["RealityGeometries"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RealityGeometries",
            dependencies: []),
        .testTarget(
            name: "RealityGeometriesTests",
            dependencies: ["RealityGeometries"]),
    ]
)
