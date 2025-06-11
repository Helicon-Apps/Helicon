// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Helicon",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "HeliconFoundation",
            targets: ["HeliconFoundation"]
        ),
        .library(
            name: "HeliconUI",
            targets: ["HeliconUI"]
        ),
        .library(
            name: "HeliconFirebase",
            targets: ["HeliconFirebase"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.14.0")),
    ],
    targets: [
        .target(
            name: "HeliconFoundation"
        ),
        .target(
            name: "HeliconUI",
            dependencies: ["HeliconFoundation"],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .target(
            name: "HeliconFirebase",
            dependencies: [
                "HeliconFoundation",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk")
            ]
        )
    ]
)
