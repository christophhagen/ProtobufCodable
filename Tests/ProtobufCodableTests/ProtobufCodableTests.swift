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

    private func roundTrip<T>(_ codable: T) throws where T: Codable, T: Equatable {
        let data = try ProtobufEncoder().encode(codable)
        print(data.bytes)
        let decoded: T = try ProtobufDecoder().decode(from: data)

        XCTAssertEqual(decoded, codable)
        if decoded != codable {
            print("Encoding: \(codable)")
            print("Data: \(data.bytes)")
        }
    }

    func testNestedNilValues() throws {
        let intContainer = NilNestedContainer(integer: 123, string: nil, array: [])
        try roundTrip(intContainer)

        let stringContainer = NilNestedContainer(integer: nil, string: "Some", array: [])
        try roundTrip(stringContainer)

        let arrayContainer = NilNestedContainer(
            integer: nil, string: nil, array: [nil, true, nil, nil, false, nil])
        try roundTrip(arrayContainer)

        let arrayContainerWithNil = NilNestedContainer(
            integer: nil, string: nil, array: [nil])
        try roundTrip(arrayContainerWithNil)
    }

    func testNestedOptionalArrays() throws {
        let empty = NilArrayContainer(integer: 123, array: [])
        try roundTrip(empty)

        let nilArray = NilArrayContainer(integer: 123, array: nil)
        try roundTrip(nilArray)

        let arrayWithNil = NilArrayContainer(integer: 123, array: [nil])
        try roundTrip(arrayWithNil)

        let arrayWithNil2 = NilArrayContainer(integer: 123, array: [nil, true])
        try roundTrip(arrayWithNil2)
    }

    func testStringKeys() throws {
        let container = StringKeyContainer(
            abc: -123,
            bcd: "Some",
            cde: StringKeyContainer.Nested(def: 123, efg: true))

        try roundTrip(container)
    }

    func testEnum() throws {

        enum Test: Codable {
            case a
        }

        let t = Test.a
        try roundTrip(t)
    }
}
