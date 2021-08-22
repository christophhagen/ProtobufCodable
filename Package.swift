// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProtobufCodable",
    platforms: [.macOS(.v10_10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProtobufCodable",
            targets: ["ProtobufCodable"]),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf", from: "1.17.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ProtobufCodable",
            dependencies: [],
            exclude: ["TestMessages.proto"]),
        .testTarget(
            name: "ProtobufCodableTests",
            dependencies: ["ProtobufCodable", "SwiftProtobuf"],
            exclude: ["Helper/TestMessages.proto"]),
    ]
)
