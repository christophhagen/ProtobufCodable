import Foundation
import XCTest
@testable import ProtobufCodable

func roundTripProtobuf<T>(_ message: T) throws where T: ProtobufComparable {
    let protoData = try message.protobuf.serializedData()
    let codableData = try ProtobufEncoder().encode(message)
    
    // First round trip codable
    let decodedCodable1: T = try ProtobufDecoder().decode(from: codableData)
    XCTAssertEqual(message, decodedCodable1)

    // Then decode the protobuf data
    let decodedCodable2: T = try ProtobufDecoder().decode(from: protoData)
    XCTAssertEqual(message, decodedCodable2)

    // Finale decode codable data as a protobuf
    let decodedProtobuf = try T.ProtobufType(serializedData: codableData)
    XCTAssertEqual(T.init(protoObject: decodedProtobuf), message)
}

func roundTripCodable<T>(type: T.Type = T.self, _ codable: T) throws where T: Codable, T: Equatable {
    let data = try ProtobufEncoder().encode(codable)
    print(data.bytes)
    let decoded: T = try ProtobufDecoder().decode(from: data)

    XCTAssertEqual(decoded, codable)
    if decoded != codable {
        print("Encoding: \(codable)")
        print("Data: \(data.bytes)")
    }
}

func roundTripCodable<T>(_ type: T.Type = T.self, _ values: T...) throws where T: Codable, T: Equatable {
    try values.forEach { try roundTripCodable(type: type, $0) }
}

