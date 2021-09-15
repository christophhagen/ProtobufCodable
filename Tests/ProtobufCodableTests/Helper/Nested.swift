import Foundation

struct Nested: Codable {
    
    enum CodingKeys: Int, CodingKey {
        case double = 1
        case uint = 2
    }
    
    var double: Double = 0
    
    var uint: UInt32 = 0
    
}

extension Nested: ProtobufComparable {
    
    var protobuf: PB_NestedMessage.Nested {
        .with {
            $0.double = double
            $0.uint = uint
        }
    }
}
