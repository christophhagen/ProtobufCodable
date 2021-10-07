import Foundation
import XCTest
@testable import ProtobufCodable

private class Base: Codable {

    let some: Int

    init(some: Int) {
        self.some = some
    }
}

private class Child: Base, Equatable, CustomStringConvertible {

    let more: String

    init(some: Int, more: String) {
        self.more = more
        super.init(some: some)
    }

    enum CodingKeys: CodingKey {
        case more
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.more = try container.decode(String.self, forKey: .more)
        try super.init(from: try container.superDecoder())
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(more, forKey: .more)

        try super.encode(to: container.superEncoder())
    }

    static func == (lhs: Child, rhs: Child) -> Bool {
        lhs.some == rhs.some && rhs.more == lhs.more
    }

    var description: String {
        "some: \(self.some), more: \(more)"
    }
}

final class InheritanceTests: XCTestCase {

    func testInheritance() throws {
        print("some".data(using: .utf8)!.bytes)
        print("more".data(using: .utf8)!.bytes)
        print("456".data(using: .utf8)!.bytes)
        let value = Child(some: 123, more: "456")
        try roundTripCodable(value)
    }
}
