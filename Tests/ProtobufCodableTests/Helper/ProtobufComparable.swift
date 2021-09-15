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

protocol ProtobufComparable: Codable {
    
    associatedtype ProtobufType: SwiftProtobuf.Message, Equatable
    
    var protobuf: ProtobufType { get }
    
    init()
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
