import Foundation
import SwiftProtobuf
import ProtobufCodable
import XCTest

protocol ProtobufComparable: Codable, Equatable {
    
    associatedtype ProtobufType: SwiftProtobuf.Message, Equatable
    
    var protobuf: ProtobufType { get }
    
    init()

    init(protoObject: ProtobufType)
}

extension ProtobufComparable {
    
    /**
     Compare an instance to its protobuf equivalent.
     - Parameter object: The protobuf object to compare.
     - Returns: `true`, if the protobuf representation is equal to the provided object.
     */
    func isEqual(to object: ProtobufType) -> Bool {
        protobuf == object
    }
}

func roundTrip<T>(_ block: (inout T) -> Void) throws where T: ProtobufComparable {
    var message = T()
    block(&message)
    let data = try message.protobuf.serializedData()
    let data2 = try ProtobufEncoder().encode(message)
    // print("Proto: \(data.bytes)")
    // print("Data:  \(data2.bytes)")
    let decodedCodable: T = try ProtobufDecoder().decode(from: data)
    XCTAssertEqual(message, decodedCodable)
    let decodedProtobuf = try T.ProtobufType(serializedData: data2)
    XCTAssertEqual(decodedProtobuf, message.protobuf)

    let decoded: T = try ProtobufDecoder().decode(from: data)
    XCTAssertEqual(decoded, message)
}

func roundTrip<T>(_ message: T) throws where T: ProtobufComparable {
    let protoData = try message.protobuf.serializedData()
    let codableData = try ProtobufEncoder().encode(message)
    // print("Proto: \(protoData.bytes)")
    // rint("Data:  \(codableData.bytes)")
    let decodedCodable1: T = try ProtobufDecoder().decode(from: codableData)
    XCTAssertEqual(message, decodedCodable1)

    let decodedCodable2: T = try ProtobufDecoder().decode(from: protoData)
    XCTAssertEqual(message, decodedCodable2)

    let decodedProtobuf = try T.ProtobufType(serializedData: codableData)
    XCTAssertEqual(T.init(protoObject: decodedProtobuf), message)
}
