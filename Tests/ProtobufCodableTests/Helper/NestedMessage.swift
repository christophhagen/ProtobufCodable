import Foundation

struct NestedMessage: Codable {
    
    enum CodingKeys: Int, CodingKey {
        case basic = 1
        case nested = 2
    }
    
    var basic: BasicMessage
    
    var nested: Nested
    
    init(basic: BasicMessage = BasicMessage(), nested: Nested = Nested()) {
        self.basic = basic
        self.nested = nested
    }
    
    init() {
        self.basic = BasicMessage()
        self.nested = Nested()
    }
}

extension NestedMessage: ProtobufComparable {
    
    var protobuf: PB_NestedMessage {
        .with {
            $0.basic = basic.protobuf
            $0.nested = nested.protobuf
        }
    }
}
