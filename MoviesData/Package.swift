// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MoviesData",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "MoviesData",
            targets: ["MoviesData"]),
    ],
    dependencies: [
        .package(path: "../MoviesDomain"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0")
    ],
    targets: [
        .target(
            name: "MoviesData",
            dependencies: [
                "MoviesDomain",
                "Moya"
            ],
            path: "Sources/MoviesData"),
        .testTarget(
            name: "MoviesDataTests",
            dependencies: ["MoviesData"],
            path: "Tests/MoviesDataTests"),
    ]
)