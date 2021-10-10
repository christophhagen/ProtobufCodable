// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ProtobufCodable",
    products: [
        .library(
            name: "ProtobufCodable",
            targets: ["ProtobufCodable"]),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf",
                 url: "https://github.com/apple/swift-protobuf",
                 from: "1.17.0"),
    ],
    targets: [
        .target(
            name: "ProtobufCodable",
            dependencies: []),
        .testTarget(
            name: "ProtobufCodableTests",
            dependencies: ["ProtobufCodable", "SwiftProtobuf"],
            exclude: ["Helper/TestMessages.proto"]),
    ]
)
