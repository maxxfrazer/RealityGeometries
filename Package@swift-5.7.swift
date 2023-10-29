// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealityGeometries",
    platforms: [.iOS(.v15), .macOS(.v12), .macCatalyst(.v15)],
    products: [.library(name: "RealityGeometries", targets: ["RealityGeometries"])],
    dependencies: [],
    targets: [
        .target(name: "RealityGeometries", dependencies: []),
        .testTarget(name: "RealityGeometriesTests", dependencies: ["RealityGeometries"])
    ]
)
