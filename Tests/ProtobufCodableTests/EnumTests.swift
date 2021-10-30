import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

private struct EnumContainer: Codable, Equatable, ProtobufComparable {
    
    var protobuf: PB_EnumContainer {
        .with { $0.intEnum = .init(rawValue: intEnum.rawValue)! }
    }
    
    init() {
        self.intEnum = .universal
    }
    
    init(intEnum: TestEnum) {
        self.intEnum = intEnum
    }
    
    init(protoObject: PB_EnumContainer) {
        self.intEnum = TestEnum(rawValue: protoObject.intEnum.rawValue) ?? .universal
    }
    
    typealias ProtobufType = PB_EnumContainer
    
    enum TestEnum: Int, Codable {
        case universal = 0
        case other = 1
        case third = 2
    }
    
    var intEnum: TestEnum
    
    enum CodingKeys: Int, CodingKey {
        case intEnum = 1
    }
}

final class EnumTests: XCTestCase {

    enum NormalTest: Codable {
        case a
    }

    func testEncodeEnum() throws {
        // Note: Normal enums call KeyedEncoder.nestedContainer() with the case as
        // a string CodingKey. The nestedContainer itself is empty
        let input = Data([
            11, // Wire type `stringKey`, key length 1
            97, // Key `a`
            2, // Wire type `lengthDelimited`
            0 // Length 0
        ])
        try encoded(NormalTest.a, matches: input)
    }

    func testEnum() throws {
        try roundTripCodable(NormalTest.a)
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
    
    func testProtobufEnum() throws {
        try roundTripProtobuf(EnumContainer(intEnum: .other))
    }
}
