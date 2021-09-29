//
//  File.swift
//  
//
//  Created by iMac on 12.09.21.
//

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
/*
func roundTrip<T: ProtobufComparable>(_ original: T, omitDefaults: Bool = true, compareBinary: Bool = true) throws {
    let data = try ProtobufEncoder(omitDefaultValues: omitDefaults).encode(original)
    let decoded = try T.ProtobufType.init(serializedData: data)
    XCTAssertEqual(original.protobuf, decoded)
    if compareBinary {
        XCTAssertEqual(try decoded.serializedData().bytes, data.bytes)
    }
}

func compareBinaries<T: ProtobufComparable>(_ original: T) throws {
    try roundTrip(original)
    try roundTrip(original, omitDefaults: false)
}

func compareBinaries<T: ProtobufComparable>(omitDefaults: Bool = true, _ block: (inout T) -> Void) throws {
    var original = T()
    block(&original)
    try roundTrip(original, omitDefaults: omitDefaults)
}

func roundTripBoth<T: ProtobufComparable>(_ block: (inout T) -> Void) throws {
    var original = T()
    block(&original)
    try roundTrip(original, compareBinary: false)
    try roundTrip(original, omitDefaults: false, compareBinary: false)
}

/**
 Encode an instance using ProtobufEncoder and decode it using SwiftProtobuf.
 
 Both options (true/false) for omitting default values are checked for correctness.
 For the case where defaults are ommited, the binary representation is compared between both encodings.
 */
func compareBinaryWithoutDefaults<T: ProtobufComparable>(_ original: T) throws {
    try roundTrip(original)
    try roundTrip(original, omitDefaults: false, compareBinary: false)
}

func compareBinaryWithoutDefaults<T: ProtobufComparable>(_ block: (inout T) -> Void) throws {
    var original = T()
    block(&original)
    try compareBinaryWithoutDefaults(original)
}
*/
func roundTrip<T>(_ block: (inout T) -> Void) throws where T: ProtobufComparable {
    var message = T()
    block(&message)
    let data = try message.protobuf.serializedData()
    let data2 = try ProtobufEncoder().encode(message)
    print("Proto: \(data.bytes)")
    print("Data:  \(data2.bytes)")
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
    print("Proto: \(protoData.bytes)")
    print("Data:  \(codableData.bytes)")
    let decodedCodable1: T = try ProtobufDecoder().decode(from: codableData)
    XCTAssertEqual(message, decodedCodable1)

    let decodedCodable2: T = try ProtobufDecoder().decode(from: protoData)
    XCTAssertEqual(message, decodedCodable2)

    let decodedProtobuf = try T.ProtobufType(serializedData: codableData)
    XCTAssertEqual(T.init(protoObject: decodedProtobuf), message)
}
