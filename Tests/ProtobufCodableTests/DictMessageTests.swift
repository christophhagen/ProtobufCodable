import XCTest
import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {

    func roundTrip(_ block: (inout DictContainer) -> Void) throws {
        var message = DictContainer()
        block(&message)
        let data = try message.protobuf.serializedData()
        let data2 = try ProtobufEncoder().encode(message)
        print("Proto: \(data.bytes)")
        print("Data:  \(data2.bytes)")
        let decodedCodable: DictContainer = try ProtobufDecoder().decode(from: data)
        XCTAssertEqual(message, decodedCodable)
        let decodedProtobuf = try DictContainer.ProtobufType(serializedData: data2)
        XCTAssertEqual(decodedProtobuf, message.protobuf)

        let decoded: DictContainer = try ProtobufDecoder().decode(from: data)
        XCTAssertEqual(decoded, message)
    }
    
    func testStringDict() throws {
        try roundTrip {
            $0.stringDict = ["Some" : 123, "More" : 234]
        }
    }
    
    func testUIntDict() throws {
        // Proto       [18,  7, 8, 123, 18, 3, 24, 234, 1, 18, 10, 8, 128, 27, 18, 5, 77, 200, 1, 0, 0]
        // First pair:  18,  7, 8, 123, 18, 3, 24, 234, 1
        //   Key:               8, 123
        //                1,Varint 123
        //   Value:                     18, 3, 24, 234, 1
        //                         2,Length 3
        //      BasicMessage              3,Varint 234
        // Second pair: 18, 10, 8, 128, 27, 18, 5, 77, 200, 1, 0, 0

        let codableData: [UInt8] =
            [18, 65, // field 2, wire type 2 (length), length 65
                8, 128, 27, // Field 1, type 0 (varint), value: 3456
                18, 60, // Field 2, type 2 (length), length 60
                    9, 0, 0, 0, 0, 0, 0, 0, 0,
                    21, 0, 0, 0, 0,
                    24, 0,
                    32, 0,
                    40, 0,
                    48, 0,
                    56, 0,
                    64, 0,
                    77, 200, 1, 0, 0,
                    81, 0, 0, 0, 0, 0, 0, 0, 0,
                    93, 0, 0, 0, 0,
                    97, 0, 0, 0, 0, 0, 0, 0, 0,
                    104, 0,
                    114, 0,
                    122, 0,
             18, 65, // field 2, wire type 2 (length), length 65
                8, 123, // Field 1, type 0 (varint), value: 123
                18, 61, // Field 2, type 2 (length), length 61
                    9, 0, 0, 0, 0, 0, 0, 0, 0,
                    21, 0, 0, 0, 0,
                    24, 234, 1, // Field 3, type 0 (varint), value: 456
                    32, 0,
                    40, 0,
                    48, 0,
                    56, 0,
                    64, 0,
                    77, 0, 0, 0, 0,
                    81, 0, 0, 0, 0, 0, 0, 0, 0,
                    93, 0, 0, 0, 0,
                    97, 0, 0, 0, 0, 0, 0, 0, 0,
                    104, 0,
                    114, 0,
                    122, 0]
        try roundTrip {
            $0.uintDict = [123 : BasicMessage(int32: 234),
                           3456 : BasicMessage(fixedInt32: 456)]
        }
    }
    
    func testIntDict() throws {
        try roundTrip {
            $0.intDict = [123 : BasicMessage(int32: 234),
                          -345 : BasicMessage(fixedInt32: 456)]
        }
    }
}


