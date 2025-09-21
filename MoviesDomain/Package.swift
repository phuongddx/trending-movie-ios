// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MoviesDomain",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "MoviesDomain",
            targets: ["MoviesDomain"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MoviesDomain",
            dependencies: [],
            path: "Sources/MoviesDomain"),
        .testTarget(
            name: "MoviesDomainTests",
            dependencies: ["MoviesDomain"],
            path: "Tests/MoviesDomainTests"),
    ]
)