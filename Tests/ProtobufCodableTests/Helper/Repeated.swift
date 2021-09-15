import Foundation

struct Repeated: Codable {
    
    enum CodingKeys: Int, CodingKey {
        case unsigneds = 1
        case messages
    }
    
    var unsigneds: [UInt32] = []
    
    var messages: [BasicMessage] = []
}

extension Repeated: ProtobufComparable {
    
    var protobuf: PB_Repeated {
        .with {
            $0.unsigneds = unsigneds
            $0.messages = messages.map { $0.protobuf }
        }
    }
}

