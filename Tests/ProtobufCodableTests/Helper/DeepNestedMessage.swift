import Foundation

struct DeepNestedMessage: Codable {
    
    enum CodingKeys: Int, CodingKey {
        case basic = 1
        case nested
    }
    
    var basic: BasicMessage
    
    var nested: NestedMessage

    init(basic: BasicMessage = BasicMessage(), nested: NestedMessage = NestedMessage()) {
        self.basic = basic
        self.nested = nested
    }
    
    init() {
        self.basic = BasicMessage()
        self.nested = NestedMessage()
    }
}

extension DeepNestedMessage: ProtobufComparable {

    init(protoObject: PB_DeepNestedMessage) {
        self.basic = .init(protoObject: protoObject.basic)
        self.nested = .init(protoObject: protoObject.nested)
    }
    
    var protobuf: PB_DeepNestedMessage {
        .with {
            $0.basic = basic.protobuf
            $0.nested = nested.protobuf
        }
    }
}

