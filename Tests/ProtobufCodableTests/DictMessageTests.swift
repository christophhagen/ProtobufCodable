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

    func testRawStringDict() throws {
        try roundTripCodable(strIntDict)
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

    func testDictionaries() throws {
        // [8, 0, 18, 4, 122, 101, 114, 111]
        try roundTripCodable([Int : String].self, [.zero : "zero"])

        // [8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int : String].self, [.zero : "zero", 123 : "123"])

        // [8, 10, 4, 122, 101, 114, 111, 16, 0, 4, 8, 123, 16, 123]
        try roundTripCodable([String : Int].self, ["zero" : .zero, "123" : 123])

        // Either: [7, 8, 123, 18, 3, 49, 50, 51,   8, 8, 0, 18, 4, 122, 101, 114, 111]
        // or:     [8, 8, 0, 18, 4, 122, 101, 114, 111,   7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int32 : String].self, [.zero : "zero", 123 : "123"])

        // [6, 12, 18, 3, 110, 105, 108, 8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int32? : String].self, [.zero : "zero", 123 : "123", nil : "nil"])

        // [2, 12, 20, 8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int32? : String?].self, [.zero : "zero", 123 : "123", nil : nil])

    }
}

