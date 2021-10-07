import Foundation
import XCTest
@testable import ProtobufCodable

private func encode<T>(_ value: T) throws -> Data where T: Encodable {
    do {
        return try ProtobufEncoder().encode(value)
    } catch {
        print("Failed to encode \(value): \(error)")
        throw error
    }
}

private func decode<T>(_ data: Data) throws -> T where T: Decodable {
    do {
        return try ProtobufDecoder().decode(from: data)
    } catch {
        print("Failed to decode: \(error)\n\(data.bytes)")
        throw error
    }
}

private func deserialize<T>(_ type: T.Type, _ data: Data) throws -> T.ProtobufType where T: ProtobufComparable {
    do {
        return try T.ProtobufType(serializedData: data)
    } catch {
        print("Failed to deserialize: \(error)\n\(data.bytes)")
        throw error
    }
}

func roundTripProtobuf<T>(_ message: T) throws where T: ProtobufComparable {
    let protoData = try message.protobuf.serializedData()
    let codableData = try encode(message)

    // First round trip codable
    let decodedCodable1: T = try decode(codableData)
    XCTAssertEqual(message, decodedCodable1)

    // Then decode the protobuf data
    let decodedCodable2: T = try decode(protoData)
    XCTAssertEqual(message, decodedCodable2)

    // Finally decode codable data as a protobuf
    let decodedProtobuf = try deserialize(T.self, codableData)
    XCTAssertEqual(T.init(protoObject: decodedProtobuf), message)
}

func roundTripCodable<T>(type: T.Type = T.self, _ codable: T) throws where T: Codable, T: Equatable {
    let data = try encode(codable)
    let decoded: T = try decode(data)

    XCTAssertEqual(decoded, codable)
    if decoded != codable {
        print("Encoding: \(codable)")
        print("Data: \(data.bytes)")
    }
}

func roundTripCodable<T>(_ type: T.Type = T.self, _ values: T...) throws where T: Codable, T: Equatable {
    try values.forEach { try roundTripCodable(type: type, $0) }
}

