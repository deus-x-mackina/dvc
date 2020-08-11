// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dvc",
    dependencies: [
        .package(
            url: "https://github.com/JohnSundell/Files.git",
            from: "4.1.1"),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(
            name: "dvc",
            dependencies: [
                "Files",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)
