import XCTest
import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {

    func roundTrip(_ block: (inout DictContainer) -> Void) throws {
        var message = DictContainer()
        block(&message)
        let data = try message.protobuf.serializedData()
        let data2 = try ProtobufEncoder().encode(message)
        // print("Proto: \(data.bytes)")
        // print("Data:  \(data2.bytes)")
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


