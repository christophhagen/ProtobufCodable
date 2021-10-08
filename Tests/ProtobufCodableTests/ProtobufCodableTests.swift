import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

private struct NilNestedContainer: Codable, Equatable {

    enum CodingKeys: Int, CodingKey {
        case integer = 1
        case string = 32
        case array = 8
    }

    let integer: Int?

    let string: String?

    let array: [Bool?]
}

private struct NilArrayContainer: Codable, Equatable {

    enum CodingKeys: Int, CodingKey {
        case integer = 1
        case array = 42
    }

    let integer: Int?
    let array: [Bool?]?
}

private struct StringKeyContainer: Codable, Equatable {

    let abc: Int

    let bcd: String

    let cde: Nested

    struct Nested: Codable, Equatable {

        let def: Int

        let efg: Bool
    }
}

final class ProtobufCodableTests: XCTestCase {

    func testNestedNilValues() throws {
        let intContainer = NilNestedContainer(integer: 123, string: nil, array: [])
        try roundTripCodable(intContainer)

        let stringContainer = NilNestedContainer(integer: nil, string: "Some", array: [])
        try roundTripCodable(stringContainer)

        let arrayContainer = NilNestedContainer(
            integer: nil, string: nil, array: [nil, true, nil, nil, false, nil])
        try roundTripCodable(arrayContainer)

        let arrayContainerWithNil = NilNestedContainer(
            integer: nil, string: nil, array: [nil])
        try roundTripCodable(arrayContainerWithNil)
    }

    func testNestedOptionalArrays() throws {
        let empty = NilArrayContainer(integer: 123, array: [])
        try roundTripCodable(empty)

        let nilArray = NilArrayContainer(integer: 123, array: nil)
        try roundTripCodable(nilArray)

        let arrayWithNil = NilArrayContainer(integer: 123, array: [nil])
        try roundTripCodable(arrayWithNil)

        let arrayWithNil2 = NilArrayContainer(integer: 123, array: [nil, true])
        try roundTripCodable(arrayWithNil2)
    }

    func testStringKeys() throws {
        let container = StringKeyContainer(
            abc: -123,
            bcd: "Some",
            cde: StringKeyContainer.Nested(def: 123, efg: true))

        try roundTripCodable(container)
    }

    func testEnum() throws {

        enum Test: Codable {
            case a
        }

        let t = Test.a
        try roundTripCodable(t)
    }
    
    func testIntEnum() throws {

        enum Test: Int, Codable {
            case a = 123
        }

        let t = Test.a
        try roundTripCodable(t)
    }
    
    func testNestedEnum() throws {
        
        struct Test: Codable, Equatable {
            
            let a: TestEnum
            
            enum TestEnum: Codable {
                case one
                case two
            }
        }
        
        let t = Test(a: .two)
        try roundTripCodable(t)
    }
    
    func testSet() throws {
        
        let test: Set<Int> = [1,2,3,4,5]
        try roundTripCodable(test)
    }
    
    func testNestedSet() throws {
        
        struct Test: Codable, Equatable {
            
            let a: Set<Int>
        }
        
        let test = Test(a: [1,2,3,4,5])
        try roundTripCodable(test)
    }

    private let rounds = 50000

    let message = BasicMessage(
        double: 3.14, float: 3.14, int32: 123, int64: 123,
        unsignedInt32: 123, unsignedInt64: 123, signedInt32: 123, signedInt64: 123,
        fixedInt32: 123, fixedInt64: 123, signedFixedInt32: 123, signedFixedInt64: 123,
        boolean: true, string: "Some", bytes: Data([42, 42, 42]))

    func testPerformanceCodable() throws {
        var encoder = ProtobufEncoder()
        encoder.omitDefaultValues = true

        measure {
            for _ in 0..<rounds {
                let _ = try! encoder.encode(message)
            }
        }
    }

    func testPerformanceProtobuf() throws {
        let message2 = message.protobuf
        measure {
            for _ in 0..<rounds {
            let _ = try! message2.serializedData()
            }
        }
    }
}
