import XCTest
import ProtobufCodable

final class NestedMessagesTests: XCTestCase {

    private func compareToProto(_ value: StructWithStructs) throws {
        try compare(value)
    }

    func testNestedMessages() throws {
        try compareToProto(.init(one: .init(int64: 123), two: .init(int64: 123)))
    }

    func testEmptyMessage() throws {
        try compareToProto(.init(one: .init(double: 123), two: .init()))
    }

    func testNestedNilMessage() throws {
        try compareToProto(.init(one: .init(double: 123), two: nil))
    }

    func testOtherEmptyMessage() throws {
        try compareToProto(.init(one: .init(), two: .init(sint32: 123)))
    }

    func testEmptyAndNilMessage() throws {
        try compareToProto(.init(one: .init(), two: nil))
    }

    func testAllEmptyMessages() throws {
        try compareToProto(.init(one: .init(), two: .init()))
    }
}
