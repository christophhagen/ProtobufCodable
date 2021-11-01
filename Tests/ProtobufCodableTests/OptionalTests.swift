import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class OptionalTests: XCTestCase {


    func testOptionalUInt8() throws {
        try roundTripCodable(Optional<UInt8>.self, .min, nil, .max)
    }

    func testOptionals() throws {
        try encoded(Optional<UInt8>(123), matches: Data([123]))
        try encoded(Optional<UInt8>(nil), matches: Data([]))
    }

    func testOptionalString() throws {
        try roundTripCodable(Optional<String>.self, "Some", nil, "More")
    }

    func testOptionalStruct() throws {
        try roundTripCodable(Optional<BasicMessage>.self, .init(double: 3.14, int32: 123), nil)
    }

    func testOptionalArray() throws {
        try roundTripCodable(Optional<[Int]>.self, [1,2,3], nil)
    }

    func testOptionalDict() throws {
        try roundTripCodable(Optional<[Int : String]>.self, [1 : "Some"], nil)
    }
}
