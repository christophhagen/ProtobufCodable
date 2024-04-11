import Foundation
import SwiftProtobuf
import ProtobufCodable
import XCTest

protocol ProtoComparable: Codable, Equatable {

    associatedtype ProtoEquivalent: SwiftProtobuf.Message, Equatable

    var proto: ProtoEquivalent { get }
}

func compare<T>(_ value: T) throws where T: ProtoComparable {
    let valueProto = value.proto
    let protoData = try valueProto.serializedData()

    var encoder = ProtobufEncoder()
    encoder.sortKeysDuringEncoding = true
    let codableData = try encoder.encode(value)
    XCTAssertEqual(Array(codableData), Array(protoData))

    let decoder = ProtobufDecoder()
    let decoded = try decoder.decode(T.self, from: protoData)
    XCTAssertEqual(value, decoded)

    let decodedProto = try T.ProtoEquivalent(serializedData: codableData)
    XCTAssertEqual(decodedProto, valueProto)
}
