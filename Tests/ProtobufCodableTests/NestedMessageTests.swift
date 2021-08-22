import XCTest
import ProtobufCodable
import SwiftProtobuf

final class NestedMessageTests: XCTestCase {
    
    private let basic = BasicMessage(
        double: 3.14,
        int64: -123456789012345,
        unsignedInt32: 123456789,
        signedInt64: -234567890123456,
        fixedInt32: 2334567890,
        signedFixedInt32: 123456,
        boolean: false,
        string: "SomeText")
    
    private var pbBasic: PB_BasicMessage {
        basic.protobuf
    }
    
    func testNestedMessage() throws {
        let nested = Nested(double: -3.14, uint: 123567890)
        
        let nestedMessage = NestedMessage(basic: basic, nested: nested)
        let pbNested = PB_NestedMessage.Nested.with {
            $0.double = nested.double
            $0.uint = nested.uint
        }
        let pbMessage = PB_NestedMessage.with {
            $0.basic = pbBasic
            $0.nested = pbNested
        }
        
        XCTAssertEqual(try ProtobufEncoder().encode(nested), try pbNested.serializedData())
        XCTAssertEqual(try ProtobufEncoder().encode(basic).bytes, try pbBasic.serializedData().bytes)
        
        let pbData = try pbMessage.serializedData()
        let codableData = try ProtobufEncoder().encode(nestedMessage)
        XCTAssertEqual(pbData.bytes, codableData.bytes)
    }
    
    func testEmptyNestedMessage() throws {
        let nested = Nested()
        let basic = BasicMessage(
            double: 3.14)
        
        let nestedMessage = NestedMessage(basic: basic, nested: nested)
        let pbNested = PB_NestedMessage.Nested()
        let pbBasic = PB_BasicMessage.with {
            $0.double = basic.double
        }
        let pbMessage = PB_NestedMessage.with {
            $0.basic = pbBasic
            $0.nested = pbNested
        }
        
        XCTAssertEqual(try ProtobufEncoder().encode(nested), try pbNested.serializedData())
        XCTAssertEqual(try ProtobufEncoder().encode(basic).bytes, try pbBasic.serializedData().bytes)
        
        let pbData = try pbMessage.serializedData()
        let codableData = try ProtobufEncoder().encode(nestedMessage)
        XCTAssertEqual(pbData.bytes, codableData.bytes)
    }
    
    func testDeepNestedMessage() throws {
        let nested = Nested(double: -3.14, uint: 123567890)
        
        let nestedMessage = NestedMessage(basic: basic, nested: nested)
        let pbNested = PB_NestedMessage.Nested.with {
            $0.double = nested.double
            $0.uint = nested.uint
        }
        let pbMessage = PB_NestedMessage.with {
            $0.basic = pbBasic
            $0.nested = pbNested
        }
        
        let pbDeep = PB_DeepNestedMessage.with {
            $0.basic = pbBasic
            $0.nested = pbMessage
        }
        
        let codableDeep = DeepNestedMessage(basic: basic, nested: nestedMessage)
        
        let pbData = try pbDeep.serializedData()
        let codableData = try ProtobufEncoder().encode(codableDeep)
        XCTAssertEqual(pbData.bytes, codableData.bytes)
    }
}
