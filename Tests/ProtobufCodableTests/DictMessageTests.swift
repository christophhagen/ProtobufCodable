import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {

    private var strIntDict: [String : Int32] {
        ["Some" : 123, "More" : 234]
    }

    private let pair1 = Data([
        8, // length of pair
        10, // field 1, length-delimited
        4, 83, 111, 109, 101, // length + "Some"
        16, // field 2, varint
        123, // varint 123
    ])

    private let pair2 = Data([
        9, // length of pair
        10, // field 1, length-delimited
        4, 77, 111, 114, 101, // length + "More"
        16, // field 2, varint
        234, 1, // varint 234
    ])

    func testEncodeStringDict() throws {
        try encoded(strIntDict, matches: pair1 + pair2, pair2 + pair1)
    }

    func testEncodeStructWithDict() throws {
        let input = DictContainer(stringDict: strIntDict)
        let data1 = Data([10] /* Field 1, length-delimited */ + pair1 +
                         [10] /* Field 1, length-delimited */ + pair2)
        let data2 = Data([10] /* Field 1, length-delimited */ + pair2 +
                         [10] /* Field 1, length-delimited */ + pair1)
        try encoded(input, matches: data1, data2)
    }

    func testStringDict() throws {
        try roundTripProtobuf(DictContainer(stringDict: strIntDict))
    }
    
    func testUIntDict() throws {
        try roundTripProtobuf(DictContainer(
            uintDict: [123 : BasicMessage(int32: 234),
                       3456 : BasicMessage(fixedInt32: 456)]))
    }
    
    func testIntDict() throws {
        try roundTripProtobuf(DictContainer(
            intDict: [123 : BasicMessage(int32: 234),
                      -345 : BasicMessage(fixedInt32: 456)]))
    }
}

