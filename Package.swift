// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ProtobufCodable",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(
            name: "ProtobufCodable",
            targets: ["ProtobufCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
    ],
    targets: [
        .target(
            name: "ProtobufCodable"),
        .testTarget(
            name: "ProtobufCodableTests",
            dependencies: [
                "ProtobufCodable",
                    .product(name: "SwiftProtobuf", package: "swift-protobuf")]),
    ]
)
