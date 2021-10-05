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
}
